# Dotfile configurations for home-manager
# Handles direct file copying and templating for configurations not covered by programs

{ config, pkgs, ... }:

{
  # XDG configurations that need direct file management
  xdg.configFile = {
    # Starship configuration (from dot_config/readonly_starship.toml)
    "starship.toml".source = ../../../home/dot_config/readonly_starship.toml;

    # Tmux configuration (from dot_config/tmux/)
    # Note: tmux plugin management will need manual setup post-migration
    "tmux/tmux.conf".source = ../../../home/dot_config/tmux/readonly_tmux.conf;
    "tmux/conf".source = ../../../home/dot_config/tmux/conf;

    # Alacritty configuration
    "alacritty/alacritty.toml".source = ../../../home/dot_config/alacritty/alacritty.toml;

    # Ghostty configuration (current preference)
    "ghostty/config".source = ../../../home/dot_config/ghostty/config;

    # Other essential configs
    "aerospace/aerospace.toml".source = ../../../home/dot_config/aerospace/aerospace.toml;
    "bat/config".source = ../../../home/dot_config/bat/config;
    "eza/theme.yml".source = ../../../home/dot_config/eza/theme.yml;
    "lazygit/config.yml".source = ../../../home/dot_config/lazygit/config.yml;
    "mise/config.toml".source = ../../../home/dot_config/mise/config.toml;
    "opencode".source = ../../../home/dot_config/opencode;
    "sesh/sesh.toml".source = ../../../home/dot_config/sesh/sesh.toml;
    "trippy/trippy.toml".source = ../../../home/dot_config/trippy/trippy.toml;
    "vale/dot_vale.ini".source = ../../../home/dot_config/vale/dot_vale.ini;
    "yamlfmt/dot_yamlfmt".source = ../../../home/dot_config/yamlfmt/dot_yamlfmt;
  };

  # Home directory files
  home.file = {
    # Shell configuration files
    ".aliases".source = ../../../home/dot_aliases;
    ".vimrc".source = ../../../home/dot_vimrc;
    ".screenrc".source = ../../../home/dot_screenrc;
    ".prettierrc.json5".source = ../../../home/dot_prettierrc.json5;
    ".dprint.json".source = ../../../home/dot_dprint.json;

    # Git templates
    ".git-templates".source = ../../../home/dot_git-templates;

    # GPG configuration
    ".gnupg/gpg-agent.conf".source = ../../../home/private_dot_gnupg/gpg-agent.conf;

    # Other configuration files
    "commitlint.config.js".source = ../../../home/commitlint.config.js;
    ".czrc".source = ../../../home/dot_czrc;
    ".dircolors".source = ../../../home/dot_dircolors;
    ".gitignore".source = ../../../home/dot_gitignore;
    ".zimrc".source = ../../../home/dot_zimrc;

    # Vimium options (browser)
    "vimium-options.json".source = ../../../home/vimium-options.json;

    # Work-specific encrypted aliases (if they exist)
    # Note: GPG decryption will need to be handled during activation
  };

  # Environment variables from various shell configs
  home.sessionVariables = {
    # Ensure EZA colors are set
    EZA_COLORS = "da=1;34:gm=1;34:Su=1;34";

    # Path additions (these will be handled by programs.zsh and other tools)
    # PATH additions are managed by individual tools like mise, homebrew, etc.
  };

  # Shell integration files
  programs.zsh.initExtraFirst = ''
    # Source aliases if home-manager file management isn't used
    [ -f ~/.aliases ] && source ~/.aliases

    # Work-specific aliases
    [ -f ~/.work-aliases ] && source ~/.work-aliases
  '';
}
