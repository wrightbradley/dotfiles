# dotfiles

## Development Machine Bootstrapping using Ansible

```bash
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
Basically an idempotent environment setup and configuration manager that was originally derived from my dotfiles bash script.

## To Execute

All you need to do is configure your vars within /inventories and /vars and then run bootstrap.sh

## TODO:

- Download git completion ("https://github.com/git/git/blob/master/contrib/completion/git-completion.zsh")
