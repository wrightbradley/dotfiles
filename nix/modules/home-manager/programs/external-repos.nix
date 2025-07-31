# External Repository Management for Nix
# Handles git repositories that chezmoi manages via .chezmoiexternal.toml

{ config, pkgs, lib, ... }:

{
  # Neovim configuration from external repo
  # Replaces: [".config/nvim"] type = "git-repo" url = "https://github.com/wrightbradley/nvim.git"
  xdg.configFile."nvim" = {
    source = pkgs.fetchFromGitHub {
      owner = "wrightbradley";
      repo = "nvim";
      rev = "main"; # Should be pinned to specific commit in production
      sha256 = "0000000000000000000000000000000000000000000000000000"; # Will need actual hash
    };
    recursive = true;
  };

  # Alacritty themes from external repo
  # Replaces: [".config/alacritty/themes"] type = "git-repo" url = "https://github.com/alacritty/alacritty-theme.git"
  xdg.configFile."alacritty/themes" = {
    source = pkgs.fetchFromGitHub {
      owner = "alacritty";
      repo = "alacritty-theme";
      rev = "master"; # Should be pinned to specific commit
      sha256 = "0000000000000000000000000000000000000000000000000000"; # Will need actual hash
    };
    recursive = true;
  };

  # Tokyo Night theme for bat
  # Replaces: [".config/bat/themes/tokyonight.nvim"] type = "git-repo" url = "https://github.com/folke/tokyonight.nvim.git"
  xdg.configFile."bat/themes/tokyonight.nvim" = {
    source = pkgs.fetchFromGitHub {
      owner = "folke";
      repo = "tokyonight.nvim";
      rev = "main"; # Should be pinned to specific commit
      sha256 = "0000000000000000000000000000000000000000000000000000"; # Will need actual hash
    };
    recursive = true;
  };

  # Note: In practice, these would use specific commit hashes instead of branch names
  # for reproducibility. The sha256 hashes would need to be calculated for each repo.
  #
  # Alternative approach: Use home-manager's `programs.git.includes` to clone repos
  # during activation, but this is less pure than the fetchFromGitHub approach.
}
