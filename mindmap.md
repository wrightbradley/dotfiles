# ansible-dotfiles

## Flow of the Ansible Play
```
VARS:
* Setup Variables
  * setup_aliases
  * setup_bash
  * setup_brew (defaults to homebrew if system is macOS)
  * setup_chromebook
  * setup_color
  * setup_fonts
  * setup_git
  * setup_icons
  * setup_screen
  * setup_tmux
  * setup_vim
  * setup_vscode
  * setup_zsh

ansible-playbook -i localhost main.yml "<tags>" "<extra_vars>"

main.yml
	--> PRE_TASKS
		--> * Verify system configuration (macOS vs Linux) //TODO
		--> * Backup current configuration (rsync + tar.gz + datetime) //TODO
		--> * Create ~/.dotfiles directory and clone repo inside (DONE) //TODO
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



