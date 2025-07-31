# Package management with profile awareness and modular structure
{ config, pkgs, lib, ... }:

let
  cfg = config.myHome.programs;
  inherit (lib) mkEnableOption mkIf;

  # Profile-aware package selection
  workPackages = with pkgs; [
    # Work-specific tools
    slack zoom-us microsoft-teams
    1password 1password-cli
    terraform-ls
    azure-cli google-cloud-sdk
  ];

  personalPackages = with pkgs; [
    # Personal entertainment/media
    spotify discord steam vlc handbrake obs-studio
  ];

  # Core development packages
  developmentPackages = with pkgs; [
    # Development tools - Git ecosystem
    git git-delta git-cliff gitleaks gh ghq

    # Development tools - Editors and terminal
    neovim vim tmux screen
    direnv mise pre-commit
    shellcheck shfmt

    # Development languages and runtimes
    nodejs yarn python3 poetry pipenv rye pdm
    go rust openjdk maven gradle ant ruby perl lua

    # DevOps and Infrastructure
    kubectl kubectx k9s helm kustomize
    docker docker-compose kubernetes-helm
    terraform-ls ansible ansible-lint

    # Cloud tools
    awscli2 k3d minikube stern

    # Security tools
    gnupg pinentry_mac cosign openssh openssl
  ];

  # System utilities and CLI tools
  cliPackages = with pkgs; [
    # Core utilities
    coreutils gnu-sed grep bash zsh
    curl wget rsync tree htop bottom glances
    jq yq dasel unzip zip bzip2 xz

    # File management and search
    eza fd ripgrep fzf bat dust jdupes yazi

    # Network and system
    nmap mtr netcat socat wireguard-tools

    # Text and data processing
    pandoc vale proselint tealdeer csvlens sqlite

    # Build and analysis tools
    make automake autoconf cmake tokei ast-grep
    codespell prettier stylua yapf ruff

    # Container tools
    dive skopeo

    # Terminal utilities
    expect parallel dos2unix rename watch entr
    pwgen mas usage

    # Modern CLI enhancements
    zoxide starship gum glow
  ];

  # Media processing tools
  mediaPackages = with pkgs; [
    ffmpeg ffmpegthumbnailer imagemagick gifsicle
    fastfetch
  ];

in
{
  imports = [
    ./external-repos.nix
    ./secrets.nix
  ];

  options.myHome.programs = {
    development = mkEnableOption "development tools" // { default = true; };
    cli = mkEnableOption "CLI utilities" // { default = true; };
    media = mkEnableOption "media tools" // { default = true; };
    work = mkEnableOption "work-specific tools" // { default = config.myHome.profileType == "work"; };
    personal = mkEnableOption "personal tools" // { default = config.myHome.profileType == "personal"; };
  };

  config = {
    home.packages =
      (mkIf cfg.development developmentPackages) ++
      (mkIf cfg.cli cliPackages) ++
      (mkIf cfg.media mediaPackages) ++
      (mkIf cfg.work workPackages) ++
      (mkIf cfg.personal personalPackages);
  };
}
