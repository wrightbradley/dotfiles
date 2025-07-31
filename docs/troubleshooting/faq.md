# Frequently Asked Questions (FAQ)

This document addresses common questions, issues, and misconceptions about the Nix-based dotfiles configuration system.

## 🔰 Getting Started

### Q: What is this system and why should I use it?
**A:** This is a declarative dotfiles management system built on Nix, nix-darwin, and home-manager. Benefits include:

- **Reproducible environments**: Same configuration produces identical results
- **Atomic updates**: Changes apply completely or not at all (no partial states)
- **Easy rollbacks**: Instantly revert to previous working configurations
- **Profile management**: Switch between work and personal setups
- **Declarative configuration**: Everything is defined in version-controlled files

### Q: How is this different from my current Homebrew + dotfiles setup?
**A:** Key differences:

| Traditional Setup | Nix-based Setup |
|------------------|-----------------|
| Imperative package management | Declarative package management |
| Manual dotfile symlinking | Automatic configuration generation |
| No rollback capability | Built-in rollbacks |
| Single configuration | Multiple profiles (work/personal) |
| Scattered configuration | Centralized configuration |

### Q: Will this replace my existing setup completely?
**A:** Not entirely. The system uses a hybrid approach:
- **Nix packages**: CLI tools, development environments (~80% of packages)
- **Homebrew casks**: macOS-specific GUI applications (~20% of packages)
- **Configuration management**: Fully replaced by Nix modules

### Q: How long does the initial setup take?
**A:** Typical timeline:
- **Nix installation**: 5-10 minutes
- **Initial configuration build**: 20-45 minutes (downloads packages)
- **Subsequent builds**: 2-5 minutes (uses cache)
- **Profile switches**: 30 seconds - 2 minutes

## 🛠️ Installation and Setup

### Q: Do I need to uninstall my existing Homebrew setup?
**A:** No, you can run both systems in parallel during migration:
- Existing Homebrew remains functional
- Nix packages are isolated in `/nix/store`
- Gradually migrate packages as you gain confidence

### Q: What if the installation fails?
**A:** Common solutions:

1. **Check Xcode Command Line Tools**:
   ```bash
   xcode-select --install
   ```

2. **Verify Nix installation**:
   ```bash
   source ~/.nix-profile/etc/profile.d/nix.sh
   nix --version
   ```

3. **Clear Nix store and reinstall**:
   ```bash
   sudo rm -rf /nix
   curl -L https://install.determinate.systems/nix | sh -s -- install
   ```

### Q: Can I install this on multiple machines?
**A:** Yes! This is a major benefit:
- Clone the repository on each machine
- Customize hostname in flake.nix if needed
- Run the same installation command
- Optionally use different profiles per machine

### Q: What happens to my existing dotfiles?
**A:** The system doesn't modify existing dotfiles:
- Nix-managed configurations take precedence
- Existing files remain as backup
- You can gradually migrate custom configurations

## ⚙️ Configuration and Customization

### Q: How do I add a new package?
**A:** Add to the appropriate package list:

```bash
# Edit the programs module
nvim ~/.config/dotfiles/nix/modules/home-manager/programs/default.nix

# Add to the relevant package list
developmentPackages = with pkgs; [
  # existing packages...
  your-new-package
];

# Apply changes
darwin-rebuild switch --flake ~/.config/dotfiles/nix
```

### Q: How do I remove a package I don't want?
**A:** Remove from package lists or disable categories:

```bash
# Option 1: Remove from package list
# Edit modules/home-manager/programs/default.nix and remove the package

# Option 2: Disable entire categories
# Edit home.nix
config.myHome.programs = {
  media.enable = false;  # Disables all media tools
};
```

### Q: Can I use my own custom aliases?
**A:** Yes, modify the shell configuration:

```bash
# Edit shell configuration
nvim ~/.config/dotfiles/nix/modules/home-manager/shell/default.nix

# Add to shellAbbrs section
shellAbbrs = {
  # existing aliases...
  myalias = "my-command";
  proj = "cd ~/Projects";
};
```

### Q: How do I switch between work and personal profiles?
**A:** Use different flake targets:

```bash
# Switch to work profile
darwin-rebuild switch --flake ~/.config/dotfiles/nix#Bradleys-MacBook-Pro

# Switch to personal profile
darwin-rebuild switch --flake ~/.config/dotfiles/nix#Bradleys-MacBook-Pro-personal
```

### Q: Can I add macOS-specific applications?
**A:** Yes, through the Homebrew integration:

```bash
# Edit Homebrew configuration
nvim ~/.config/dotfiles/nix/modules/darwin/homebrew/default.nix

# Add to casks list
casks = [
  # existing casks...
  "your-new-application"
];
```

## 🔧 Daily Usage

### Q: How do I update packages?
**A:** Update and rebuild:

```bash
# Update package definitions
nix flake update

# Apply updates
darwin-rebuild switch --flake ~/.config/dotfiles/nix
```

### Q: How do I undo changes if something breaks?
**A:** Use Nix's built-in rollback:

```bash
# See available generations
darwin-rebuild --list-generations

# Rollback to previous generation
sudo /nix/var/nix/profiles/system-{previous-number}-link/activate

# Or rollback home-manager only
home-manager switch --generation {number}
```

### Q: Why is my build taking so long?
**A:** Common causes and solutions:

1. **First build**: Downloads all packages (normal)
2. **Cache miss**: Some packages need to build from source
3. **Network issues**: Check internet connection
4. **Disk space**: Clean up with `nix-collect-garbage -d`

### Q: How do I check what's currently installed?
**A:** Various inspection commands:

```bash
# List installed packages
nix-env -q

# Show current generation
darwin-rebuild --list-generations

# Show package differences
nvd diff /nix/var/nix/profiles/system-{1,2}-link
```

## 🐛 Troubleshooting

### Q: I'm getting "package not found" errors
**A:** Solutions:

1. **Search for correct package name**:
   ```bash
   nix search nixpkgs package-name
   ```

2. **Check if package is available in unstable**:
   ```bash
   nix search nixpkgs-unstable package-name
   ```

3. **Use unstable overlay**:
   ```nix
   packages = with pkgs; [
     unstable.package-name
   ];
   ```

### Q: My configuration won't build
**A:** Debugging steps:

1. **Check syntax**:
   ```bash
   nix flake check
   ```

2. **Get detailed errors**:
   ```bash
   darwin-rebuild switch --flake ./nix --show-trace
   ```

3. **Test individual modules**:
   ```bash
   nix eval .#darwinConfigurations.Bradleys-MacBook-Pro.config.mySystem
   ```

### Q: Home-manager and nix-darwin configurations are inconsistent
**A:** Ensure profile consistency:

```bash
# Check system profile
darwin-option mySystem.profileType

# Check home profile
home-manager option myHome.profileType

# They should match
```

### Q: I have permission issues with /nix
**A:** Fix Nix store permissions:

```bash
# Fix ownership
sudo chown -R root:nixbld /nix

# Restart Nix daemon
sudo launchctl kickstart -k system/org.nixos.nix-daemon
```

### Q: Builds are failing with "disk full" errors
**A:** Clean up Nix store:

```bash
# Remove old generations
nix-collect-garbage -d

# Remove specific generations
nix-env --delete-generations 1 2 3

# Clean up and optimize store
nix-store --gc --print-roots
nix-store --optimize
```

## 🔄 Advanced Usage

### Q: Can I create my own modules?
**A:** Yes! Follow the module development pattern:

```nix
# Create module file
{ config, lib, pkgs, ... }:
let
  cfg = config.myHome.myModule;
in
{
  options.myHome.myModule = {
    enable = lib.mkEnableOption "my module";
    # additional options...
  };

  config = lib.mkIf cfg.enable {
    # module implementation
  };
}
```

### Q: How do I manage secrets?
**A:** Currently using GPG encryption (legacy), migrating to sops-nix:

```bash
# Current: GPG encrypted files (from chezmoi)
# Future: sops-nix integration (planned)

# For now, manage secrets manually or keep using chezmoi for secrets
```

### Q: Can I use this with CI/CD?
**A:** Yes, example GitHub Actions:

```yaml
- name: Test configuration
  run: |
    nix flake check
    nix build .#darwinConfigurations.Bradleys-MacBook-Pro.system
```

### Q: How do I pin specific package versions?
**A:** Use overlays or specific nixpkgs versions:

```nix
# In overlays/default.nix
custom-packages = final: prev: {
  my-package = prev.my-package.overrideAttrs (oldAttrs: {
    version = "specific-version";
    src = prev.fetchurl {
      url = "...";
      sha256 = "...";
    };
  });
};
```

## 🚀 Performance and Optimization

### Q: How can I speed up builds?
**A:** Optimization strategies:

1. **Use binary cache**:
   ```bash
   # Add to nix.conf
   substituters = https://cache.nixos.org https://nix-community.cachix.org
   ```

2. **Enable parallel builds**:
   ```bash
   # Add to nix.conf
   max-jobs = auto
   cores = 0
   ```

3. **Clean up regularly**:
   ```bash
   nix-collect-garbage -d
   ```

### Q: Why is the Nix store so large?
**A:** The Nix store keeps all package versions and dependencies:
- Multiple package versions for different configurations
- Build dependencies that are cached
- Old generations that haven't been garbage collected

Regular cleanup with `nix-collect-garbage` manages size.

### Q: Can I share the Nix store between users?
**A:** Yes, but requires careful setup:
- Single-user installation shares store automatically
- Multi-user installation isolates profiles but shares store
- All users benefit from cached builds

## 📚 Learning and Community

### Q: Where can I learn more about Nix?
**A:** Learning resources:

- **[Nix Pills](https://nixos.org/guides/nix-pills/)**: Comprehensive tutorial series
- **[nix-darwin Manual](https://daiderd.com/nix-darwin/manual/)**: macOS-specific documentation
- **[Home Manager Manual](https://nix-community.github.io/home-manager/)**: User environment management
- **[NixOS Wiki](https://nixos.wiki/)**: Community knowledge base

### Q: How do I get help with issues?
**A:** Support channels:

1. **Check this documentation**: Start with troubleshooting guides
2. **Search existing issues**: GitHub repository issues
3. **Community forums**:
   - [NixOS Discourse](https://discourse.nixos.org/)
   - [r/NixOS](https://www.reddit.com/r/NixOS/)
   - [Nix Community Discord](https://discord.gg/RbvHtGa)

### Q: Can I contribute to this project?
**A:** Yes! Contributions welcome:

- **Bug reports**: File issues with detailed reproduction steps
- **Feature requests**: Suggest improvements or new modules
- **Code contributions**: Submit pull requests with documentation
- **Documentation**: Help improve or expand documentation

### Q: Is this production-ready?
**A:** The system is designed for production use:

- **Stability**: Built on proven Nix technology
- **Rollback capability**: Safe to experiment
- **Extensive testing**: Comprehensive test suite
- **Real-world usage**: Used daily by the maintainer

Start with a non-critical machine to gain confidence before migrating primary systems.

---

**Still have questions?** Check the [troubleshooting documentation](./troubleshooting/) or open an issue on the GitHub repository with detailed information about your setup and the problem you're experiencing.
