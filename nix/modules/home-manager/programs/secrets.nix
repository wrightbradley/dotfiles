# Secrets Management for Nix Migration
# Handles encrypted files that chezmoi manages with GPG

{ config, pkgs, lib, userData, isWork, ... }:

{
  # Work-specific encrypted aliases
  # Replaces: encrypted_dot_work-aliases.asc
  home.file.".work-aliases" = lib.mkIf isWork {
    # Option 1: Use sops-nix for secret management (recommended)
    # source = config.sops.secrets.work-aliases.path;

    # Option 2: Manual GPG decryption during activation (interim solution)
    text = ''
      # Work-specific aliases would be decrypted here
      # This requires manual migration of encrypted content
      # or implementing sops-nix integration

      # Placeholder for work aliases that were in encrypted_dot_work-aliases.asc
      # These need to be manually decrypted and added, or migrated to sops-nix
    '';
  };

  # Work-specific fish configuration
  # Replaces: dot_config/fish/conf.d/encrypted_work.fish.asc
  xdg.configFile."fish/conf.d/work.fish" = lib.mkIf isWork {
    text = ''
      # Work-specific fish configuration
      # Decrypted content from encrypted_work.fish.asc would go here

      # This needs manual migration from the encrypted file
    '';
  };

  # GPG configuration for handling encrypted files
  programs.gpg = {
    enable = true;
    # Use the hardware key from chezmoi data
    publicKeys = [
      {
        source = pkgs.fetchurl {
          url = "https://github.com/${userData.ghuser}.gpg";
          sha256 = "0000000000000000000000000000000000000000000000000000"; # Needs actual hash
        };
      }
    ];
  };

  # Conditional ignore patterns (from .chezmoiignore)
  # In chezmoi: {{- if ne .system "work" }} .work-aliases.asc {{- end }}
  # In Nix: We handle this through conditional file creation above

  # TODO: Implement sops-nix integration for proper secret management
  # This would involve:
  # 1. Converting GPG-encrypted files to sops format
  # 2. Adding sops-nix to the flake inputs
  # 3. Configuring sops keys and secrets
  # 4. Using config.sops.secrets.* instead of manual decryption
}
