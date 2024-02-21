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

Setups and configures various dotfiles, installs packages, and configures the host machine.
This repo strives to be as declarative and idempotent as possible while keeping configurations up-to-date and in sync across many different hosts.

To facilitate these goals, this repo uses [chezmoi](https://www.chezmoi.io/) and [ansible](https://docs.ansible.com/ansible/latest/getting_started/index.html).

## To Execute

You need to create a chezmoi config file under the XDG Base Directory. For macOS, that would be: `~/.config/chezmoi/`
Chezmoi supports different [file formats](https://www.chezmoi.io/reference/configuration-file/), but I currently use TOML.

My config file for chezmoi is pretty simple. There are a few unique components related to GPG encryption support for chezmoi. (NOTE: replace the example email address with the correct email address used for the GPG keys)

```toml
encryption = "gpg"
pager = "less -R"

[edit]
command = "nvim"

[gpg]
symmetric = false
recipient = "me@example.com"

[pinentry]
command = "pinentry"

[data]
recipient = "me@example.com"
ghuser = "wrightbradley"
hwkey = "0xABCDEF1234567XYZ"
```

With this config in place, you can then install chezmoi and use your GitHub dotfiles repo to bootstrap a new machine:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
```

## Task List

- Hook Ansible into chezmoi bootstrap step
- Move Homebrew package install from Ansible to chezmoi. Standardize on chezmoi.
- Support downloading project code repos with chezmoi.

## MacOS Tiling

### yabai tiling window manager

```bash
brew install koekeishiya/formulae/yabai
yabai --start-service
```

### skhd Hotkey Daemon

```bash
brew install koekeishiya/formulae/skhd
skhd --start-service
```
