# dotfiles
## Development Machine Bootstrapping using Ansible

```
                \||/
                |  @___oo        DOTFILES INSTALLATION
      /\  /\   / (__,,,,|        RELEASE: 1.1a
     ) /^\) ^\/ _)
     )   /^\/   _)
     )   _ /  / _)
 /\  )/\/ ||  | )_)
<  >      |(,,) )__)
 ||      /    \)___)\
 | \____(      )___) )___
  \______(_______;;; __;;;
```

Setups and configures various dotfiles as well as install packages.
Basically an idempotent environment setup and configuration manager.
Derived from my dotfiles bash script.

## Prerequisites

* To setup up the prerequisties, you can run `bootstrap.sh`

### Git Submodules

* Homebrew
* osx tools
* go
* python-pip

#### How to add git submodules
```
git submodule init
git submodule update --init --recursive --remote
git submodule foreach 'git fetch origin --tags && git checkout master && git pull'
git pull origin master
```

### Python/Pip on macOS

```
sudo easy_install pip
pip install ansible --user <yourusername>
# Python 2
export PATH=$PATH:/Users/<yourusername>/Library/Python/2.7/bin
# Python 3
export PATH=$PATH:/Users/<yourusername>/Library/Python/3.7/bin
```

### Python/Pip on Debian 10

```
sudo apt update
sudo apt install python3-venv python3-pip
pip3 install --user ansible ansible-lint
export PATH="$PATH:/home/<yourusername>/.local/bin"
```

## Flow of the Ansible Play

```
VARS:
* zsh or bash
* homebrew or package manager (defaults to homebrew if system is macOS)

ansible-playbook -i localhost main.yml "<tags>"

main.yml
	--> PRE_TASKS
		--> * Verify system configuration (TODO)
		--> * Backup current configuration (TODO)
		--> * Create ~/.dotfiles directory and clone repo inside (DONE)
		--> * Make ssh directory (DONE) and create ssh config (TODO)
		--> * Ensure correct permissions on HOME directory (DONE)
	--> ROLES
		--> system
			--> * Installs base packages system package manager
		--> homebrew
			--> * Installs homebrew
			--> * Installs base casks and taps (TODO : re-add list)
		--> aliases
			--> * Templates out aliases file
			--> * Symlinks aliases file into HOME directory
		--> git
			--> * Configures gitconfig
			--> * Configures git completion (TODO : tag bash/zsh)
		--> bash
			--> * Templates out bashrc file
			--> * Symlinks bashrc file into HOME directory
		--> zsh
			--> * Installs oh-my-zsh
			--> * Installs zsh plugins
			--> * Installs zsh themes
			--> * Templates out zshrc file
			--> * Symlinks zshrc file into HOME directory
			--> * Templates out p10k.zsh file
			--> * Symlinks p10k.zsh file into HOME directory
		--> chromebook
			--> Installs Signal Messenger
			--> Installs gnome-terminal
		--> color_icons_fonts
			--> Installs colorls for file/directory colors and icons
			--> Install base16_shell for terminal color theming
			--> Installs patched nerd fonts
		--> go
			--> Installs and configures go
		--> python-pip
			--> Installs pip
			--> Installs pip packages
		--> screenrc_tmux
			--> Installs screenrc
			--> Templates out and symlinks screenrc
			--> Installs tmux
			--> Templates out and symlinks tmux
		--> vim
			--> Installs vim
			--> Templates out .vimrc
			--> Installs vim plugins
		--> vscode
			--> Templates out VS Code settings.json file
	--> POST_TASKS
		--> * Change user's shell if zsh is selected

		```
