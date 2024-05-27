# dotfiles

## Machine Bootstrapping

```bash
                \||/
                |  @___oo        DOTFILES INSTALLATION
      /\  /\   / (__,,,,|        RELEASE: 2.0
     ) /^\) ^\/ _)
     )   /^\/   _)
     )   _ /  / _)
 /\  )/\/ ||  | )_)
<  >      |(,,) )__)
 ||      /    \)___)\
 | \____(      )___) )___
  \______(_______;;; __;;;
```

Setups and configures various dotfiles, installs packages, and configures the
host machine. This repo strives to be as declarative and idempotent as possible
while keeping configurations up-to-date and in sync across many different hosts.

To facilitate these goals, this repo uses [chezmoi](https://www.chezmoi.io/) and
[ansible](https://docs.ansible.com/ansible/latest/getting_started/index.html).

## To Execute

You need to create a chezmoi config file under the XDG Base Directory. For
macOS, that would be: `~/.config/chezmoi/` Chezmoi supports different
[file formats](https://www.chezmoi.io/reference/configuration-file/), but I
currently use TOML.

My config file for chezmoi is pretty simple. There are a few unique components
related to GPG encryption support for chezmoi. (NOTE: replace the example email
address with the correct email address used for the GPG keys)

```toml
encryption = "gpg"
pager = "delta"

[edit]
command = "nvim"

[gpg]
symmetric = false
recipient = "me@example.com"

[pinentry]
command = "pinentry"

[data]
system = "personal"
email_work = "me@work.com"
email_personal = "me@personal.com"
ghuser = "wrightbradley"
hwkey = "0xABCDEF1234567XYZ"
```

With this config in place, you can then install chezmoi and use your GitHub
dotfiles repo to bootstrap a new machine:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
```

## Task List

- Hook Ansible into chezmoi bootstrap step
- Move Homebrew package install from Ansible to chezmoi. Standardize on chezmoi.
- Support downloading project code repos with chezmoi.

## TODO

Ensure all Homebrew taps and casks are managed by Ansible.

```bash
brew info --json=v2 --installed \
    | jq -r '.formulae[]|select(any(.installed[]; .installed_on_request)).full_name'
```

```brew
ansible
ansible-lint
ant
argo
argocd
asdf
asitop
aws-iam-authenticator
awscli
bash
bash-completion
bitwarden-cli
oven-sh/bun/bun
cdk8s
miniscruff/changie/changie
chart-testing
checkov
chezmoi
cli53
cmake
cmctl
codespell
colima
colordiff
container-diff
cookiecutter
coreutils
cue
curl
cypher-shell
detect-secrets
direnv
dive
docker
docker-credential-helper
docker-credential-helper-ecr
docker-slim
dos2unix
earthly/earthly/earthly
aws/tap/ec2-instance-selector
aws/tap/eks-node-viewer
eksctl
entr
eslint
expect
eza
faas-cli
fd
ffmpeg
flake8
charmbracelet/tap/freeze
fzf
theden/gcopy/gcopy
gh
gifski
git
git-cliff
git-xargs
glances
glow
gnu-sed
gnupg
go
go-jsonnet
goreleaser/tap/goreleaser
gradle
grafana
grafana-agent
grep
grpcurl
hadolint
helm
norwoodj/tap/helm-docs
hey
hopenpgp-tools
htop
httrack
iperf3
istioctl
jinja2-cli
ankitpokhrel/jira-cli/jira-cli
jq
jsonnet-bundler
mike-engel/jwt-cli/jwt-cli
k2tf
k3d
k9s
krew
kube-linter
kube-ps1
kubeconform
kubectx
kubernetes-cli
kubescape
kubescape/tap/kubescape-cli
kubeseal
kustomize
kwok
lazygit
logcli
luarocks
make
maven
mimirtool
minikube
mosh
mtr
lindell/multi-gitter/multi-gitter
mysql-client
ncurses
neofetch
neomutt
neovim
nmap
fairwindsops/tap/nova
nvm
openssh
openssl@3
osx-cpu-temp
pandoc
parallel
pdm
perl
pgcli
pinentry-mac
pipenv
pngpaste
fairwindsops/tap/polaris
popeye
postgresql@14
pre-commit
prettier
proselint
pwgen
pyenv
pyenv-virtualenv
pylint
python-argcomplete
python-platformdirs
python@3.10
python@3.11
python@3.12
pyyaml
readline
rename
ripgrep
rsync
ruby
rust
rye
screen
shellcheck
shfmt
skaffold
koekeishiya/formulae/skhd
skopeo
snyk-cli
spark
sqlite
starship
stern
stylua
tcl-tk
veeso/termscp/termscp
terraform
terraform-docs
terragrunt
terrascan
tflint
tfsec
tilt
tmux
tree
trippy
trivy
uv
vale
vcluster
velero
vhs
vim
watch
wget
whois
wireguard-tools
xz
koekeishiya/formulae/yabai
yamllint
yapf
yarn
ykman
ykpers
yq
zlib
zoxide
zsh
zsh-vi-mode
```

### Homebrew Casks

```bash
brew list --cask
```

```brew
alacritty
anytype
authy
backblaze
bartender
blackhole-2ch
discord
elgato-camera-hub
elgato-control-center
elgato-stream-deck
elgato-wave-link
firefox
font-caskaydia-cove-nerd-font
font-droid-sans-mono-nerd-font
font-fira-code-nerd-font
font-hack-nerd-font
font-symbols-only-nerd-font
google-cloud-sdk
handbrake
iterm2
keycastr
keymapp
lens
logi-options-plus
logitech-options
logseq
microsoft-teams
noto
obs
obsidian
parallels-toolbox
rancher
signal
spotify
tailscale
todoist
visual-studio-code
vlc
zoom
```

### Fix Bash PS1

```bash
bash: _kube_ps1_update_cache: command not found
bash: __git_ps1: command not found
bash: __git_ps1: command not found
bash: __git_ps1: command not found
bash: __git_ps1: command not found
bash: kube_ps1: command not found
bash: __git_ps1: command not found
```

### Add zsh to shells on linux

```bash
command -v zsh | sudo tee -a /etc/shells
```
