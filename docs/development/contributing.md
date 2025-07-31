# Contributing to the Nix Darwin Dotfiles

Thank you for your interest in contributing! This document provides guidelines for contributing to the project, whether you're reporting bugs, suggesting features, or submitting code changes.

## 🎯 How to Contribute

### Types of Contributions Welcome

1. **Bug Reports**: Help identify and fix issues
2. **Feature Requests**: Suggest new functionality or improvements
3. **Code Contributions**: Submit patches, new modules, or improvements
4. **Documentation**: Improve or expand documentation
5. **Testing**: Help test configurations and report results
6. **Package Updates**: Keep package lists current and relevant

### Before You Start

- **Search existing issues** to avoid duplicates
- **Check the documentation** to understand current functionality
- **Test your changes** thoroughly before submitting
- **Follow the coding standards** outlined in this document

## 🐛 Reporting Issues

### Bug Reports

When reporting bugs, please include:

**System Information:**
```bash
# Include output of these commands
system_profiler SPSoftwareDataType | grep "System Version"
nix --version
darwin-rebuild --version
```

**Current Configuration:**
- Profile type (work/personal)
- Any custom modifications
- Recent changes made

**Detailed Description:**
- What you expected to happen
- What actually happened
- Steps to reproduce the issue
- Any error messages or logs

**Example Bug Report:**
```markdown
## Bug Description
Git configuration not applying after profile switch

## Environment
- macOS: 13.5.2
- Nix: 2.18.1
- Profile: work

## Steps to Reproduce
1. Switch to personal profile: `darwin-rebuild switch --flake .#personal`
2. Check git config: `git config user.email`
3. Email still shows work address

## Expected Behavior
Email should change to personal address

## Actual Behavior
Email remains: bradley.wright@company.com

## Error Messages
None - configuration appears to apply successfully
```

### Feature Requests

For feature requests, please provide:

- **Clear description** of the desired functionality
- **Use case** explaining why this would be valuable
- **Proposed implementation** if you have ideas
- **Alternatives considered** and why they don't work

## 🔧 Development Setup

### Prerequisites

```bash
# Install required tools
xcode-select --install

# Install Nix with flakes support
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### Fork and Clone

```bash
# Fork the repository on GitHub, then:
git clone https://github.com/YOUR_USERNAME/dotfiles.git
cd dotfiles

# Add upstream remote
git remote add upstream https://github.com/wrightbradley/dotfiles.git
```

### Development Environment

```bash
# Enter development shell with all tools
cd nix
nix develop

# This provides:
# - nixfmt: Code formatting
# - nil: Nix language server
# - nix-tree: Dependency visualization
# - nvd: Version diff tool
```

### Testing Your Changes

```bash
# Check syntax and configuration
nix flake check

# Test build without applying
darwin-rebuild build --flake .#Bradleys-MacBook-Pro --show-trace

# Test home-manager configuration
home-manager build --flake .#bwright@Bradleys-MacBook-Pro

# Format code
nixfmt **/*.nix
```

## 📝 Coding Standards

### Nix Code Style

#### File Organization
```nix
# Standard module structure
{ config, lib, pkgs, ... }:
let
  cfg = config.myModule.section;
  inherit (lib) mkOption types mkEnableOption mkIf;
in
{
  # Options definition
  options.myModule.section = {
    enable = mkEnableOption "feature description";

    customOption = mkOption {
      type = types.str;
      default = "default-value";
      description = "Clear description of what this option does";
    };
  };

  # Configuration implementation
  config = mkIf cfg.enable {
    # Implementation using cfg options
  };
}
```

#### Naming Conventions
- **Files**: Use kebab-case for file names (`my-module.nix`)
- **Options**: Use camelCase for option names (`myOption`)
- **Variables**: Use camelCase for local variables (`myVariable`)
- **Constants**: Use UPPER_CASE for constants (`MY_CONSTANT`)

#### Code Formatting
```bash
# Format all Nix files before committing
nixfmt **/*.nix

# Check formatting
nixfmt --check **/*.nix
```

#### Option Documentation
```nix
options.myHome.myModule = {
  enable = mkEnableOption "my module functionality";

  customSetting = mkOption {
    type = types.str;
    default = "default";
    example = "example-value";
    description = lib.mdDoc ''
      Detailed description of what this option controls.

      Use markdown formatting for complex descriptions.
      Include examples and common use cases.
    '';
  };
};
```

### Module Development Guidelines

#### Option Design
- **Sensible defaults**: Provide useful defaults for all options
- **Type safety**: Use appropriate types with validation
- **Documentation**: Include clear descriptions and examples
- **Consistency**: Follow existing patterns in the codebase

#### Profile Awareness
```nix
# Make modules profile-aware when appropriate
options.myHome.myModule = {
  workFeature = mkEnableOption "work-specific feature" // {
    default = config.myHome.profileType == "work";
  };
};

config = lib.mkMerge [
  # Base configuration
  (mkIf cfg.enable {
    # Common configuration
  })

  # Profile-specific configuration
  (mkIf (cfg.enable && config.myHome.profileType == "work") {
    # Work-specific configuration
  })
];
```

#### Error Handling
```nix
config = {
  assertions = [
    {
      assertion = cfg.enable -> (cfg.requiredOption != "");
      message = "myModule.requiredOption cannot be empty when module is enabled";
    }
  ];

  warnings = lib.optionals (cfg.enable && cfg.deprecatedOption != null) [
    "myModule.deprecatedOption is deprecated, use newOption instead"
  ];
};
```

## 🧪 Testing Guidelines

### Test Your Changes

#### Syntax Testing
```bash
# Check basic syntax
nix flake check

# Test specific module
nix-instantiate --eval --strict -E 'import ./path/to/module.nix'
```

#### Build Testing
```bash
# Test full system build
nix build .#darwinConfigurations.Bradleys-MacBook-Pro.system

# Test home-manager build
nix build .#homeConfigurations."bwright@Bradleys-MacBook-Pro".activationPackage
```

#### Profile Testing
```bash
# Test both profiles build successfully
nix build .#darwinConfigurations.Bradleys-MacBook-Pro.system
nix build .#darwinConfigurations.Bradleys-MacBook-Pro-personal.system

# Test profile switching
darwin-rebuild switch --flake .#Bradleys-MacBook-Pro
darwin-rebuild switch --flake .#Bradleys-MacBook-Pro-personal
```

#### Integration Testing
```bash
# Test that your changes work with existing modules
# Check for package conflicts
# Verify option interactions
```

### Creating Tests

#### Unit Tests for Modules
```nix
# tests/modules/test-my-module.nix
{ lib }:
let
  testModule = import ../../modules/home-manager/my-module;

  testConfig = {
    myHome.myModule = {
      enable = true;
      customOption = "test-value";
    };
  };

  result = lib.evalModules {
    modules = [ testModule testConfig ];
  };
in
{
  # Test assertions
  testModuleEnables = result.config.myHome.myModule.enable == true;
  testOptionValue = result.config.myHome.myModule.customOption == "test-value";

  # Test generated configuration
  testPackageInstalled = builtins.elem pkgs.myPackage result.config.home.packages;
}
```

## 📤 Submitting Changes

### Commit Message Format

Use conventional commits format:

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code formatting changes
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(shell): add fish shell abbreviations for docker commands

Add convenient abbreviations for common docker and docker-compose
commands to improve development workflow efficiency.

fix(git): correct profile-specific email configuration

The git email was not switching correctly between work and personal
profiles due to incorrect condition in the profile logic.

docs(architecture): add module development guidelines

Provide comprehensive guidelines for developing new modules
including coding standards and testing procedures.
```

### Pull Request Process

#### Before Submitting
1. **Update documentation** if you've changed functionality
2. **Add tests** for new features
3. **Format code** using nixfmt
4. **Test thoroughly** on your system
5. **Check for breaking changes**

#### Pull Request Template
```markdown
## Description
Brief description of changes made

## Type of Change
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Syntax check passes (`nix flake check`)
- [ ] Build test passes (`darwin-rebuild build`)
- [ ] Tested on actual system
- [ ] Both profiles tested (if applicable)

## Related Issues
Fixes #(issue number)

## Additional Notes
Any additional information or context
```

#### Review Process
1. **Automated checks** must pass
2. **Code review** by maintainers
3. **Testing** on different configurations
4. **Documentation review** if applicable
5. **Final approval** and merge

### Branch Strategy

```bash
# Create feature branch
git checkout -b feature/my-new-feature

# Make changes and commit
git add .
git commit -m "feat(module): add new functionality"

# Push to your fork
git push origin feature/my-new-feature

# Create pull request on GitHub
```

## 📚 Documentation Standards

### Documentation Types

#### Code Documentation
- **Inline comments**: Explain complex logic
- **Option descriptions**: Clear, helpful descriptions
- **Module headers**: Brief description of module purpose

#### User Documentation
- **Getting started guides**: Step-by-step instructions
- **Configuration references**: Complete option documentation
- **Examples**: Real-world usage examples
- **Troubleshooting**: Common issues and solutions

#### Developer Documentation
- **Architecture documentation**: System design and patterns
- **Module development**: Guidelines for creating modules
- **Testing procedures**: How to test changes
- **Contributing guidelines**: This document

### Documentation Style

#### Writing Style
- **Clear and concise**: Use simple, direct language
- **User-focused**: Write from the user's perspective
- **Complete**: Include all necessary information
- **Examples**: Provide practical examples

#### Markdown Formatting
```markdown
# Main heading (use for major sections)
## Secondary heading (use for subsections)
### Tertiary heading (use for specific topics)

**Bold text** for emphasis
*Italic text* for subtle emphasis
`code` for inline code
```

#### Code Examples
```bash
# Use appropriate syntax highlighting
nix build .#darwinConfigurations.Bradleys-MacBook-Pro.system
```

```nix
# Show complete examples
{ config, lib, ... }:
{
  config = {
    programs.git.enable = true;
  };
}
```

## 🎉 Recognition

Contributors are recognized in several ways:

- **Contributors list**: Added to project README
- **Changelog**: Contributions noted in releases
- **Community**: Recognition in community forums

## 🆘 Getting Help

### Development Questions
- **Discussions**: Use GitHub Discussions for general questions
- **Issues**: Create issues for specific problems
- **Code review**: Ask for feedback during PR process

### Community Resources
- **NixOS Discourse**: General Nix community support
- **Matrix/Discord**: Real-time chat with community
- **Documentation**: Comprehensive project documentation

## 📋 Checklist for Contributors

### Before Contributing
- [ ] Read and understand this contributing guide
- [ ] Set up development environment
- [ ] Familiarize yourself with the codebase
- [ ] Check existing issues and discussions

### For Each Contribution
- [ ] Create focused, single-purpose changes
- [ ] Follow coding standards and conventions
- [ ] Write or update tests as needed
- [ ] Update documentation if applicable
- [ ] Test changes thoroughly
- [ ] Use clear, descriptive commit messages
- [ ] Submit pull request with complete description

### Quality Assurance
- [ ] Code passes all automated checks
- [ ] Changes are backwards compatible (or breaking changes are documented)
- [ ] Performance impact is considered
- [ ] Security implications are evaluated

Thank you for contributing to making this project better for everyone! Your contributions help create a more robust, feature-rich, and user-friendly dotfiles management system.
