# Migration from Chezmoi

This guide provides detailed instructions for migrating from a chezmoi-based dotfiles setup to the Nix-based configuration system.

## 🎯 Migration Overview

### What We're Migrating From
- **chezmoi**: Template-based dotfile management
- **Dynamic templating**: Runtime template evaluation
- **Encrypted files**: GPG-encrypted work configurations
- **External repositories**: Git repos managed by chezmoi
- **Shell scripts**: Custom installation and setup scripts

### What We're Migrating To
- **Nix modules**: Declarative configuration management
- **Static configuration**: Build-time configuration resolution
- **Profile management**: Work vs personal profile switching
- **External repos**: Nix-managed external repositories
- **Declarative packages**: Package management through Nix

## 📋 Pre-Migration Assessment

### Inventory Your Current Setup

#### 1. List chezmoi-managed files
```bash
# Show all files managed by chezmoi
chezmoi managed

# Show template files specifically
chezmoi managed | grep '\.tmpl$'

# Show encrypted files
chezmoi managed | grep '\.asc$'
```

#### 2. Analyze external repositories
```bash
# Check external repositories
cat ~/.local/share/chezmoi/.chezmoiexternal.toml

# Common external repos in our setup:
# - ~/.config/nvim (neovim configuration)
# - ~/.config/alacritty/themes (terminal themes)
# - ~/.config/bat/themes (syntax highlighting themes)
```

#### 3. Document template variables
```bash
# Check template data
cat ~/.config/chezmoi/chezmoi.toml

# Common variables used:
# - email_work / email_personal
# - profile type indicators
# - conditional feature flags
```

#### 4. Inventory encrypted files
```bash
# List encrypted files (typically work-specific)
find ~/.local/share/chezmoi -name "*.asc" -o -name "encrypted_*"

# Common encrypted files:
# - encrypted_dot_work-aliases.asc
# - Work-specific SSH configurations
# - Corporate credentials and tokens
```

## 🔄 Migration Strategy

### Phase 1: Parallel Operation
Run both systems in parallel during transition:

1. **Keep chezmoi active** for critical encrypted files
2. **Install Nix system** for package management and basic dotfiles
3. **Gradually migrate** non-sensitive configurations
4. **Test thoroughly** before full cutover

### Phase 2: Configuration Migration
Migrate configurations in order of complexity:

1. **Static files** (no templates)
2. **Simple templates** (basic variable substitution)
3. **Complex templates** (conditional logic)
4. **External repositories**
5. **Encrypted files** (manual or sops-nix)

### Phase 3: Cleanup
Remove chezmoi after successful migration.

## 📝 Detailed Migration Steps

### Step 1: Backup Current Setup

```bash
# Create backup directory
mkdir -p ~/backup/chezmoi-migration-$(date +%Y%m%d)
cd ~/backup/chezmoi-migration-$(date +%Y%m%d)

# Backup chezmoi source
cp -r ~/.local/share/chezmoi ./chezmoi-source

# Backup applied configuration
chezmoi archive > applied-config.tar.gz

# Export current package list
brew list > homebrew-packages.txt
brew list --cask > homebrew-casks.txt

# Backup current shell configuration
cp ~/.zshrc ./zshrc-backup 2>/dev/null || true
cp ~/.bashrc ./bashrc-backup 2>/dev/null || true
cp ~/.config/fish/config.fish ./fish-config-backup 2>/dev/null || true
```

### Step 2: Install Nix System (Parallel Operation)

```bash
# Install Nix
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Clone dotfiles repository
git clone https://github.com/wrightbradley/dotfiles.git ~/.config/dotfiles-nix
cd ~/.config/dotfiles-nix

# Initial bootstrap (this creates a parallel system)
nix run nix-darwin -- switch --flake ./nix#Bradleys-MacBook-Pro
```

### Step 3: Migrate Static Configuration Files

#### Git Configuration
**From chezmoi template:**
```bash
# ~/.local/share/chezmoi/dot_gitconfig.tmpl
[user]
    name = Bradley Wright
    email = {{ if eq .profile "work" }}bradley.wright@company.com{{ else }}b@rdleywright.com{{ end }}
[commit]
{{ if eq .profile "work" }}    gpgsign = true{{ end }}
```

**To Nix configuration:**
Already migrated in `modules/home-manager/shell/git.nix` with profile awareness:
```nix
programs.git = {
  userName = cfg.git.username;  # Profile-aware
  userEmail = cfg.git.email;    # Profile-aware

  extraConfig = lib.optionalAttrs (config.myHome.profileType == "work") {
    commit.gpgSign = true;
    user.signingKey = "~/.ssh/id_rsa.pub";
    gpg.format = "ssh";
  };
};
```

#### Shell Aliases
**From chezmoi:**
```bash
# ~/.local/share/chezmoi/dot_aliases
# Migrated from 400+ line alias file to structured Nix configuration
```

**To Nix configuration:**
Already migrated in `modules/home-manager/shell/default.nix`:
```nix
programs.fish.shellAbbrs = {
  # Modern CLI replacements
  ls = "eza --group-directories-first";
  cat = "bat";
  grep = "rg";
  find = "fd";

  # Git workflow
  g = "git"; ga = "git add"; gc = "git commit";

  # Development tools
  k = "kubectl"; tf = "terraform"; dc = "docker-compose";
};
```

### Step 4: Migrate External Repositories

#### Neovim Configuration
**From chezmoi external:**
```toml
# .chezmoiexternal.toml
[".config/nvim"]
    type = "git-repo"
    url = "https://github.com/wrightbradley/nvim.git"
    refreshPeriod = "168h"
```

**To Nix configuration:**
```bash
# Edit external repos module
nvim ~/.config/dotfiles-nix/nix/modules/home-manager/programs/external-repos.nix

# Calculate SHA hash first
nix-prefetch-url --unpack https://github.com/wrightbradley/nvim/archive/main.tar.gz

# Add configuration with proper hash
xdg.configFile."nvim" = {
  source = pkgs.fetchFromGitHub {
    owner = "wrightbradley";
    repo = "nvim";
    rev = "main";  # Pin to specific commit in production
    sha256 = "calculated-hash-here";
  };
  recursive = true;
};
```

#### Terminal Themes
**From chezmoi external:**
```toml
[".config/alacritty/themes"]
    type = "git-repo"
    url = "https://github.com/alacritty/alacritty-theme.git"
```

**To Nix configuration:**
Already prepared in `external-repos.nix` - needs SHA calculation:
```bash
# Calculate hash
nix-prefetch-url --unpack https://github.com/alacritty/alacritty-theme/archive/master.tar.gz

# Update configuration with real hash
```

### Step 5: Handle Encrypted Files (Work Profile)

#### Current Encrypted Files
```bash
# List encrypted files in chezmoi
find ~/.local/share/chezmoi -name "*.asc"

# Common files:
# - encrypted_dot_work-aliases.asc
# - Work-specific configurations
```

#### Migration Options

**Option A: Manual Migration (Immediate)**
```bash
# Decrypt and manually migrate
cd ~/.local/share/chezmoi
gpg --decrypt encrypted_dot_work-aliases.asc > work-aliases-decrypted

# Add to Nix configuration manually
nvim ~/.config/dotfiles-nix/nix/modules/home-manager/shell/default.nix

# Add work-specific aliases in profile condition
(lib.mkIf (config.myHome.profileType == "work") {
  programs.fish.shellAbbrs = {
    # Work-specific aliases from decrypted file
  };
})
```

**Option B: sops-nix Migration (Recommended for production)**
```bash
# Convert GPG files to sops format (planned for Phase 4)
# This provides better Nix integration

# Install sops
nix shell nixpkgs#sops

# Create sops configuration
cat > .sops.yaml << EOF
keys:
  - &admin_key your-gpg-key-id
creation_rules:
  - path_regex: secrets/.*\.yaml$
    pgp: *admin_key
EOF

# Convert encrypted files to sops format
# Detailed instructions in Phase 4 documentation
```

### Step 6: Migrate Package Management

#### Current Homebrew Packages
```bash
# Your current packages are documented in:
# docs/homebrew-install-catalog-personal.md
# docs/homebrew-install-catalog-work.md

# These have been migrated to:
# - nix/modules/home-manager/programs/default.nix (CLI tools)
# - nix/modules/darwin/homebrew/default.nix (GUI apps)
```

#### Verify Package Migration
```bash
# Check what's migrated
grep -r "package-name" ~/.config/dotfiles-nix/nix/modules/

# Test installation
darwin-rebuild build --flake ~/.config/dotfiles-nix/nix#Bradleys-MacBook-Pro
```

### Step 7: Test and Validate

#### Functional Testing
```bash
# Test shell aliases
fish -c "alias | grep git"

# Test Git configuration
git config --list | grep user

# Test packages
which eza bat ripgrep fd

# Test profile switching
darwin-rebuild switch --flake ~/.config/dotfiles-nix/nix#Bradleys-MacBook-Pro-personal
darwin-rebuild switch --flake ~/.config/dotfiles-nix/nix#Bradleys-MacBook-Pro
```

#### Compare Configurations
```bash
# Compare file contents
diff ~/.gitconfig <(chezmoi cat ~/.gitconfig)

# Check for missing aliases
comm -23 <(grep "^alias" ~/.zshrc | sort) <(fish -c "alias" | sort)
```

## 🔍 Migration Checklist

### Pre-Migration
- [ ] Backup current chezmoi setup
- [ ] Document all template variables
- [ ] List all encrypted files
- [ ] Inventory external repositories
- [ ] Note any custom scripts or functions

### During Migration
- [ ] Install Nix system in parallel
- [ ] Migrate static configuration files
- [ ] Calculate SHA hashes for external repos
- [ ] Handle encrypted files (manual or sops-nix)
- [ ] Test package installations
- [ ] Verify shell configuration
- [ ] Test Git configuration and signing

### Post-Migration Validation
- [ ] All aliases work correctly
- [ ] Git configuration is correct for both profiles
- [ ] External repositories are properly sourced
- [ ] Packages are installed and functional
- [ ] System preferences are applied
- [ ] Profile switching works
- [ ] No functionality lost from chezmoi setup

### Cleanup (After Successful Migration)
- [ ] Remove chezmoi binary
- [ ] Clean up ~/.local/share/chezmoi
- [ ] Remove old shell configuration files
- [ ] Update documentation
- [ ] Archive backup files

## ⚡ Quick Migration Commands

### Essential Migration Script
```bash
#!/bin/bash
# quick-migrate.sh - Quick migration helper

set -e

echo "🔄 Starting chezmoi to Nix migration..."

# Backup current setup
echo "📋 Creating backup..."
BACKUP_DIR=~/backup/chezmoi-migration-$(date +%Y%m%d)
mkdir -p "$BACKUP_DIR"
cp -r ~/.local/share/chezmoi "$BACKUP_DIR/chezmoi-source" 2>/dev/null || true
chezmoi archive > "$BACKUP_DIR/applied-config.tar.gz" 2>/dev/null || true

# Install Nix if not present
if ! command -v nix &> /dev/null; then
    echo "📦 Installing Nix..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    source ~/.nix-profile/etc/profile.d/nix.sh
fi

# Clone and setup Nix dotfiles
echo "🏗️ Setting up Nix configuration..."
if [ ! -d ~/.config/dotfiles-nix ]; then
    git clone https://github.com/wrightbradley/dotfiles.git ~/.config/dotfiles-nix
fi

cd ~/.config/dotfiles-nix

# Bootstrap system
echo "🚀 Bootstrapping Nix system..."
nix run nix-darwin -- switch --flake ./nix#Bradleys-MacBook-Pro

echo "✅ Basic migration complete!"
echo "📝 Next steps:"
echo "  1. Test shell aliases: fish -c 'alias'"
echo "  2. Test Git config: git config --list"
echo "  3. Check packages: which eza bat ripgrep"
echo "  4. Migrate encrypted files manually"
echo "  5. Calculate SHA hashes for external repos"

echo "🔗 See full migration guide: docs/migration/from-chezmoi.md"
```

## 🚨 Common Migration Issues

### Issue: Template Logic Translation
**Problem**: Complex chezmoi templates don't directly translate
**Solution**: Use Nix's conditional logic and profile system

```nix
# Instead of chezmoi template:
# {{ if eq .profile "work" }}work-config{{ else }}personal-config{{ end }}

# Use Nix conditional:
lib.mkIf (config.myHome.profileType == "work") {
  # work configuration
} // lib.mkIf (config.myHome.profileType == "personal") {
  # personal configuration
}
```

### Issue: External Repository SHA Hashes
**Problem**: External repos need SHA hashes for reproducibility
**Solution**: Calculate hashes with nix-prefetch-url

```bash
# For any GitHub repository
nix-prefetch-url --unpack https://github.com/owner/repo/archive/branch.tar.gz
```

### Issue: Encrypted File Access
**Problem**: GPG-encrypted files need manual handling
**Solution**: Decrypt and migrate or use sops-nix

```bash
# Quick solution: Manual decryption
gpg --decrypt encrypted_file.asc > decrypted_content

# Long-term solution: Migrate to sops-nix (Phase 4)
```

### Issue: Missing Functionality
**Problem**: Some chezmoi features don't have direct Nix equivalents
**Solution**: Implement using Nix's activation scripts or modules

```nix
# For custom setup scripts, use activation scripts
system.activationScripts.postUserActivation.text = ''
  # Custom setup logic here
'';
```

## 📊 Migration Benefits

### What You Gain
- **Reproducible builds**: Same configuration everywhere
- **Atomic updates**: All changes apply together or not at all
- **Easy rollbacks**: Instant revert to previous configurations
- **Better package management**: Declarative package installation
- **Profile management**: Clean work/personal separation
- **Version control**: Full configuration history

### What You Lose (Temporarily)
- **Dynamic templating**: Static configuration (but better reproducibility)
- **Automatic file monitoring**: Manual rebuild needed (but more predictable)
- **Simple setup**: More complex initially (but more powerful)

### Migration Timeline
- **Week 1**: Parallel operation and basic migration
- **Week 2**: Fine-tuning and testing
- **Week 3**: Advanced features and cleanup
- **Week 4**: Full cutover and documentation

This migration guide provides a comprehensive path from chezmoi to the Nix-based system while maintaining functionality and improving reproducibility.
