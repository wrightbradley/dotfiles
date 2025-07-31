# Missing packages that need homebrew fallback
# Documents packages that aren't available in nixpkgs

{ config, pkgs, ... }:

{
  # Homebrew-only packages that cannot be migrated to nixpkgs
  homebrew = {
    # Specialized tools with custom taps
    brews = [
      # AWS ecosystem
      "aquasecurity/trivy/trivy"
      "aws/tap/ec2-instance-selector"
      "aws/tap/eks-node-viewer"

      # DevOps tools with custom taps
      "charmbracelet/tap/freeze"
      "derailed/popeye/popeye"
      "fairwindsops/tap/nova"
      "fairwindsops/tap/polaris"
      "kubescape/tap/kubescape-cli"
      "norwoodj/tap/helm-docs"

      # Custom development tools
      "mike-engel/jwt-cli/jwt-cli"
      "lindell/multi-gitter/multi-gitter"
      "joshmedeski/sesh/sesh"
      "theden/gcopy/gcopy"
      "oven-sh/bun/bun"

      # System utilities
      "dockutil"  # Essential for dock management
      "mas"       # Mac App Store CLI

      # Personal-specific tools
      "cirruslabs/cli/tart"
      "fluxcd/tap/flux"
      "tilt-dev/tap/tilt"
      "veeso/termscp/termscp"

      # Work-specific tools
      "ankitpokhrel/jira-cli/jira-cli"
      "colima"

      # Platform-specific or special builds
      "asitop"      # macOS-specific
      "osx-cpu-temp"
      "macmon"

      # Specialized container tools
      "container-diff"
      "docker-credential-helper"
      "docker-credential-helper-ecr"
      "docker-slim"

      # Version-specific packages
      "postgresql@14"  # Specific version requirement

      # Node.js ecosystem
      "nvm"  # Version manager

      # Development environment managers
      "asdf"  # Multi-language version manager
      "pyenv"
      "pyenv-virtualenv"

      # Cloud-specific tools
      "cli53"
      "awslogs"

      # Specialized formatters and linters
      "chart-testing"
      "checkov"
      "detect-secrets"
      "dotenv-linter"
      "dprint"
      "terrascan"
      "tflint"
      "tfsec"
      "updatecli"

      # Media tools
      "agg"  # Specific media tool
      "gifski"

      # Network and security
      "hidapi"
      "hopenpgp-tools"
      "ykman"
      "ykpers"
      "yubico-piv-tool"
      "yubikey-personalization"

      # Development servers and services
      "grafana"
      "grafana-agent"

      # Terminal and shell enhancements
      "fish"  # Fish shell
      "zsh-vi-mode"

      # File and data processing
      "cue"  # Configuration language
      "csvlens"
      "dasel"

      # Kubernetes ecosystem (specialized)
      "argocd"
      "cdk8s"
      "cmctl"
      "eksctl"
      "faas-cli"
      "k2tf"
      "k3sup"
      "krew"
      "kube-linter"
      "kube-ps1"
      "kubeconform"
      "kubeseal"
      "kwok"
      "logcli"
      "mimirtool"
      "skaffold"
      "velero"
      "vcluster"

      # Build and packaging
      "goreleaser"

      # Documentation
      "vhs"  # Terminal recording

      # Specialized development tools
      "go-jsonnet"
      "jsonnet-bundler"
      "luarocks"

      # Network testing
      "gping"
      "iperf3"
      "sslscan"
      "trippy"
      "whois"

      # System administration
      "glances"
      "netscanner"

      # Data processing
      "pgcli"
      "mysql-client"

      # Archive and backup
      "httrack"
      "xorriso"

      # Media download
      "yt-dlp"

      # Development profiling
      "hey"
      "wrk"

      # Security scanning
      "hadolint"

      # Text processing
      "gum"
      "glow"

      # Misc utilities
      "pngpaste"
      "rename"
      "socat"
      "usage"
      "vectorcode"
      "sst/tap/opencode"  # OpenCode CLI
    ];
  };
}
