{ config, lib, ... }:
let
  cfg = config.myHome.shell;
  inherit (lib) mkOption types mkEnableOption mkIf;
in
{
  imports = [
    ./git.nix
  ];

  options.myHome.shell = {
    enable = mkEnableOption "shell configuration" // { default = true; };

    git = {
      enable = mkEnableOption "git configuration" // { default = true; };
      username = mkOption {
        type = types.str;
        default = if config.myHome.profileType == "work" then "Bradley Wright" else "wrightbradley";
        description = "Git username";
      };
      email = mkOption {
        type = types.str;
        default = if config.myHome.profileType == "work"
          then "bradley.wright@mycompany.com"
          else "b@rdleywright.com";
        description = "Git email";
      };
    };

    fish = {
      enable = mkEnableOption "fish shell" // { default = true; };
    };

    aliases = {
      enable = mkEnableOption "shell aliases" // { default = true; };
    };
  };

  config = mkIf cfg.enable {
    # GitHub CLI
    programs.gh = mkIf cfg.git.enable {
      enable = true;
      settings.version = 1;
    };

    # Fish shell configuration
    programs.fish = mkIf cfg.fish.enable {
      enable = true;

      shellAbbrs = mkIf cfg.aliases.enable {
        # Git aliases
        g = "git";
        ga = "git add";
        gaa = "git add --all";
        gc = "git commit";
        gcm = "git commit -m";
        gs = "git status";
        gp = "git push";
        gpl = "git pull";
        gl = "git log";
        gd = "git diff";
        gds = "git diff --staged";
        gr = "git restore";
        grs = "git restore --staged";

        # Modern CLI replacements
        ls = "eza --group-directories-first";
        ll = "eza -l --git --group-directories-first";
        l = "eza -la --git --group-directories-first";
        cat = "bat";
        grep = "rg";
        find = "fd";

        # Navigation aliases
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";

        # System aliases
        c = "clear";
        h = "history";

        # Development aliases
        dc = "docker-compose";
        k = "kubectl";
        tf = "terraform";
        vi = "nvim";
        vim = "nvim";

        # Tmux aliases
        t = "tmux";
        ta = "tmux attach -t";
        tn = "tmux new -s";

        # Kubernetes shortcuts
        kgn = "kubectl get nodes -o wide";
        kgp = "kubectl get pods -o wide";
        kgd = "kubectl get deployment -o wide";
        kgs = "kubectl get svc -o wide";
      };
    };

    # Starship prompt
    programs.starship = {
      enable = true;
      enableFishIntegration = cfg.fish.enable;
    };

    # Direnv for project environments
    programs.direnv = {
      enable = true;
      enableFishIntegration = cfg.fish.enable;
    };

    # Bat for syntax highlighting
    programs.bat = {
      enable = true;
      config = {
        theme = "TwoDark";
        style = "numbers,changes,header";
      };
    };

    # Fzf for fuzzy finding
    programs.fzf = {
      enable = true;
      enableFishIntegration = cfg.fish.enable;
    };

    # Zoxide for smart cd
    programs.zoxide = {
      enable = true;
      enableFishIntegration = cfg.fish.enable;
    };
  };
}
