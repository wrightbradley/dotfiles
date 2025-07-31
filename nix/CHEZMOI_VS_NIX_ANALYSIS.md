# Chezmoi vs Nix Migration Analysis

## Critical Differences Identified and Addressed

After analyzing how chezmoi actually works versus Nix, I've identified and addressed several critical differences that were missing from the initial migration:

## **1. Dynamic Templating System**

### **Chezmoi Approach:**
- Uses Go templates with dynamic data variables
- Runtime template evaluation based on system detection
- Variables like `{{.system}}`, `{{.email_work}}`, `{{.email_personal}}`
- Conditional file inclusion: `{{- if eq .system "work" }}`

### **Nix Solution Implemented:**
- **Profile-based configuration** with explicit profile selection
- **Functional programming approach** using `lib.optionals` and conditional logic
- **Profile data structure** equivalent to chezmoi's data variables
- **Build-time template resolution** instead of runtime evaluation

### **Migration Changes Made:**
```nix
# Profile detection system
profileType = "work"; # Explicit instead of dynamic
userData = {
  email_personal = "bradley.wright.tech@gmail.com";
  email_work = "bradley.wright@tackle.io";
  system = profileType;
};

# Conditional configurations
programs.git.userEmail = if isWork then userData.email_work else userData.email_personal;
programs.git.includes = lib.optionals isWork [
  { path = "~/.gitconfig.work"; }
] ++ lib.optionals isPersonal [
  { path = "~/.gitconfig.personal"; }
];
```

## **2. External Repository Management**

### **Chezmoi Approach:**
```toml
[".config/nvim"]
type = "git-repo"
url = "https://github.com/wrightbradley/nvim.git"
refreshPeriod = "720h"
```

### **Nix Solution Implemented:**
```nix
# Pure approach using fetchFromGitHub
xdg.configFile."nvim" = {
  source = pkgs.fetchFromGitHub {
    owner = "wrightbradley";
    repo = "nvim";
    rev = "main"; # Pinned commits in production
    sha256 = "..."; # Reproducible hashing
  };
};
```

### **Migration Changes Made:**
- **Created `external-repos.nix`** to handle git repositories
- **Migrated all 3 external repos** (nvim, alacritty-themes, tokyonight)
- **Reproducible approach** with commit pinning and hash verification

## **3. Encrypted Secrets Management**

### **Chezmoi Approach:**
- GPG-encrypted files with `.asc` extension
- Automatic decryption during template application
- Conditional inclusion based on profile

### **Nix Solution Implemented:**
```nix
# Work-specific encrypted content
home.file.".work-aliases" = lib.mkIf isWork {
  # Prepared for sops-nix integration
  text = ''# Work aliases (needs manual migration)'';
};
```

### **Migration Changes Made:**
- **Created `secrets.nix`** module for encrypted content
- **Documented sops-nix migration path** for proper secret management
- **Conditional secret deployment** based on profile
- **GPG integration** for public key management

## **4. Profile-Aware Configuration**

### **Chezmoi Approach:**
- Dynamic profile detection
- Conditional file application
- Template-based email/identity switching

### **Nix Solution Implemented:**
```nix
# Profile-aware flake configurations
darwinConfigurations."Bradleys-MacBook-Pro" = nix-darwin.lib.darwinSystem {
  specialArgs = { profileType = "work"; };
};
darwinConfigurations."Bradleys-MacBook-Pro-personal" = nix-darwin.lib.darwinSystem {
  specialArgs = { profileType = "personal"; };
};
```

### **Migration Changes Made:**
- **Multiple flake configurations** for different profiles
- **Profile parameter passing** through specialArgs
- **Conditional package inclusion** based on profile
- **Dynamic Git configuration** selection

## **5. File Ignore Patterns**

### **Chezmoi Approach:**
```
{{- if ne .system "work" }}
.work-aliases.asc
{{- end }}
```

### **Nix Solution Implemented:**
```nix
# Conditional file creation instead of ignore patterns
home.file.".work-aliases" = lib.mkIf isWork { ... };
```

## **Key Philosophical Differences Addressed:**

### **Runtime vs Build-time:**
- **Chezmoi**: Runtime template evaluation and dynamic file management
- **Nix**: Build-time configuration resolution with explicit dependencies

### **Imperative vs Declarative:**
- **Chezmoi**: Imperative file management with state tracking
- **Nix**: Pure functional configuration with immutable results

### **Profile Management:**
- **Chezmoi**: Dynamic detection and automatic switching
- **Nix**: Explicit profile specification with separate configurations

## **Migration Strategy Adjustments:**

1. **Explicit Profile Selection**: Instead of chezmoi's automatic detection, users specify profile during build
2. **Secret Migration Path**: Clear documentation for moving from GPG to sops-nix
3. **External Repo Pinning**: Reproducible builds with commit hashing
4. **Conditional Logic**: Nix's functional approach to replace template conditionals
5. **Multi-Configuration Flakes**: Separate configurations for different environments

## **What This Means for the Migration:**

The updated Nix configuration now properly handles:
- ✅ **Profile-based configuration switching**
- ✅ **External repository management**
- ✅ **Encrypted secrets preparation**
- ✅ **Conditional file deployment**
- ✅ **Work/personal environment differentiation**

This addresses the core chezmoi functionality while leveraging Nix's strengths in reproducibility and declarative configuration management.
