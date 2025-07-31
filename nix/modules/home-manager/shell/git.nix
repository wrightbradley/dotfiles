# Git configuration with profile awareness
{ config, lib, ... }:

let
  cfg = config.myHome.shell.git;
  inherit (lib) mkIf;
in
{
  config = mkIf cfg.enable {
    # Enhanced Git configuration with advanced features
    programs.git = {
      enable = true;
      userName = cfg.username;
      userEmail = cfg.email;

      aliases = {
        # Advanced aliases from dotfiles
        gone = "! \"git fetch -p && git for-each-ref --format '%(refname:short) %(upstream:track)' | awk '$2 == \"[gone]\" {print $1}' | xargs -r git branch -D\"";
        staash = "stash --all";
        bb = "!~/bin/better-git-branch.sh";
        yolo = "!git commit -S -m \"$(curl --silent --fail https://whatthecommit.com/index.txt)\"";
        co = "checkout";
        br = "branch";
        ci = "commit";
        st = "status";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        visual = "!gitk";
      };

      extraConfig = {
        init = {
          templatedir = "~/.git-templates";
          defaultBranch = "main";
        };

        color = {
          diff = "auto";
          status = "auto";
          branch = "auto";
          ui = true;
        };

        core = {
          excludesfile = "~/.gitignore";
          editor = "nvim";
          autocrlf = "input";
        };

        # Delta configuration for better diffs
        interactive.diffFilter = "delta --color-only";
        delta = {
          navigate = true;
          side-by-side = true;
          diff-so-fancy = true;
          paging-mode = "never";
          features = "tokyonight_night";
          dark = true;
        };

        merge = {
          conflictstyle = "diff3";
          tool = "nvimdiff";
        };

        diff = {
          colorMoved = "default";
          algorithm = "histogram";
        };

        fetch.prune = true;

        push = {
          default = "current";
          autoSetupRemote = true;
        };

        pager = {
          log = "delta";
          reflog = "delta";
          show = "delta";
          difftool = true;
        };

        difftool = {
          tool = "nvimdiff";
          prompt = false;
        };

        "difftool \"nvimdiff\"".cmd = "nvim -d \"$LOCAL\" \"$REMOTE\"";

        mergetool = {
          keepBackup = false;
        };

        "mergetool \"nvimdiff\"".cmd = "nvim -d $MERGED $LOCAL $BASE $REMOTE -c '$wincmd J' -c 'wincmd ='";

        log = {
          decorate = "auto";
          abbrevCommit = true;
          showSignature = false;
        };

        rebase.updateRefs = true;
        rerere.enabled = true;

        # URL rewriting for SSH
        "url \"git@github.com:\"".insteadOf = "https://github.com/";

        # Profile-specific configurations
      } // lib.optionalAttrs (config.myHome.profileType == "work") {
        # Work-specific git config
        commit.gpgSign = true;
        user.signingKey = "~/.ssh/id_rsa.pub";
        gpg.format = "ssh";
      };

      # Profile-specific includes (replacing chezmoi templating)
      includes = lib.optionals (config.myHome.profileType == "work") [
        { path = "~/.gitconfig.work"; }
      ] ++ lib.optionals (config.myHome.profileType == "personal") [
        { path = "~/.gitconfig.personal"; }
      ] ++ [
        # Conditional includes for specific directories
        {
          condition = "gitdir:~/Projects/writing/obsidian-vault/";
          path = "~/.gitconfig.personal";
        }
        {
          condition = "gitdir:~/.local/share/chezmoi/";
          path = "~/.gitconfig.personal";
        }
        {
          condition = "gitdir:~/.config/nvim/";
          path = "~/.gitconfig.personal";
        }
        {
          condition = "gitdir:~/Projects/code/github.com/wrightbradley/";
          path = "~/.gitconfig.personal";
        }
      ];
    };
  };
}
