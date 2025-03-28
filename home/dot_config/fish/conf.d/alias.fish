# Utility aliases and settings

# Set less or more as the default pager.
if not set -q PAGER
    if type -q less
        set -x PAGER less
    else
        set -x PAGER more
    end
end

if not set -q LESS
    set -x LESS '--ignore-case --jump-target=4 --LONG-PROMPT --no-init --quit-if-one-screen --RAW-CONTROL-CHARS'
end

# File Downloads
if type -q wget
    alias get='wget --continue --progress=bar --timestamping'
else if type -q curl
    alias get='curl --continue-at - --location --progress-bar --remote-name --remote-time'
end

# ls Aliases
alias ls='eza --group-directories-first'

alias l='ll -a' # Long format, all files
alias lr='ll -T' # Long format, recursive as a tree
alias lx='ll -sextension' # Long format, sort by extension
alias lk='ll -ssize' # Long format, largest file size last
alias lt='ll -smodified' # Long format, newest modification time last
alias lc='ll -schanged' # Long format, newest status change (ctime) last

# Navigation Aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# File Operation Aliases
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias mkdir='mkdir -p'
alias grep='rg'
alias egrep='egrep --color=always'
alias cdiff='delta'

# Viewing/Editing Aliases
alias cat='bat'
alias less='bat'
alias vi='nvim'
alias vim='nvim'
alias svi='sudo nvim'
alias view='nvim -R'

# Tmux
alias t='tmux'
alias ta='t a -t'
alias tn='t new -t'

# Network Aliases
alias ping='ping -c 10'
alias ss='ss -lntu'
alias ltcp='lsof -n -i -P | grep -i TCP'
alias lisn='lsof -n -i -P | grep -i LISTEN'
alias lssh='lsof -n -i -P | grep -i ":22"'
alias tdump='tcpdump -i eth1 "port 8080"'
alias tdumpv='tcpdump -vv -x -X -s 1500 -i eth1 "port 8080"'

alias pbcopy='gcopy'
# alias history="fc -l 1"

# Misc Functions
function whoip
    curl ip-api.com/$argv
end

function urldecode
    echo $argv | python3 -c "import sys; from urllib.parse import unquote; print(unquote(sys.stdin.read()));"
end

function grsub
    if test -z "$argv"
        echo "Please provide a submodule path/name"
    else
        git submodule deinit -f -- $argv
        rm -rf .git/modules/$argv
        git rm -f $argv
    end
end

function bak
    set LOGDATE (date +%Y%m%dT%H%M%S)
    cp "$argv" "$argv.bak.$LOGDATE"
end

# fshow - git commit browser (enter for show, ctrl-d for diff, ` toggles sort)
function fshow
    set q ""
    while true
        set out (git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" $argv | fzf --ansi --multi --no-sort --reverse --query="$q" --tiebreak=index --print-query --expect=ctrl-d --toggle-sort=\`)
        set q (echo $out | head -n 1)
        set k (echo $out | head -n 2 | tail -n 1)
        set shas (echo $out | sed '1,2d;s/^[^a-z0-9]*//;/^$/d' | awk '{print $1}')
        if test -z "$shas"
            continue
        end
        if test "$k" = ctrl-d
            git diff --color=always $shas | less -R
        else
            for sha in $shas
                git show --color=always $sha | less -R
            end
        end
    end
end

# Kubernetes Aliases
# function debug_daemonset
#     set RED 31m
#     set GREEN 32m
#     set BOLD_RED "\e[1;$RED"
#     set BOLD_GREEN "\e[1;$GREEN"
#     set ENDCOLOR "\e[0m"
#     if test -z "$argv"
#         echo "Please provide a Daemonset pod name string value"
#     else
#         set daemonsetName $argv
#         set daemonsetString "$daemonsetName-[^-]+$"
#         echo "Checking for Daemonset pods with string: $daemonsetString"
#         for node in (kubectl get nodes --no-headers | awk '{print $1}')
#             if kubectl get pods --all-namespaces -o wide --field-selector spec.nodeName="$node" --no-headers | awk '{print $2}' | /usr/bin/grep -Eq "$daemonsetString"
#                 echo -e "${BOLD_GREEN}Found daemonset pod on: $node${ENDCOLOR}"
#             else
#                 echo -e "${BOLD_RED}Missing daemonset pod on: $node${ENDCOLOR}"
#             end
#         end
#     end
# end

# function find_istio_proxy
#     set RED 31m
#     set GREEN 32m
#     set BOLD_RED "\e[1;${RED}"
#     set BOLD_GREEN "\e[1;${GREEN}"
#     set ENDCOLOR "\e[0m"
#     echo "Checking pods for istio proxy"
#     for pod in (kubectl get pods --no-headers | awk '{print $1}')
#         if kubectl get pod "$pod" -o jsonpath="{.spec.containers[*].name}" | tr -s '[:space:]' '\n' | grep -q istio-proxy
#             set istioVersion (kubectl get pod "$pod" -o jsonpath="{.spec.containers[*].image}" | tr -s '[:space:]' '\n' | grep "istio" | cut -d ":" -f2)
#             echo -e "${BOLD_GREEN}$pod has istio-proxy injected using version: $istioVersion${ENDCOLOR}"
#         else
#             echo -e "${BOLD_RED}$pod is missing istio-proxy${ENDCOLOR}"
#         end
#     end
# end

alias kgn="kubectl get nodes -o wide"
alias kgp="kubectl get pods -o wide"
alias kgd="kubectl get deployment -o wide"
alias kgs="kubectl get svc -o wide"
alias kdp="kubectl describe pod"
alias kdd="kubectl describe deployment"
alias kds="kubectl describe service"
alias kdn="kubectl describe node"

# Get All Non-Running Pods
function kpnr
    kubectl get pods -A --field-selector=status.phase!=Running | grep -v Complete
end

# Get list of nodes and their memory size
function knmem
    kubectl get no -o json | jq -r '.items | sort_by(.status.capacity.memory)[] | [.metadata.name,.status.capacity.memory] | @tsv'
end

# Get list of nodes and the number of pods running on them
function knpc
    kubectl get po -o json --all-namespaces | jq '.items | group_by(.spec.nodeName) | map({"nodeName": .[0].spec.nodeName, "count": length}) | sort_by(.count)'
end

# Get top pods based on cpu
function kptc
    kubectl top pods -A | sort --reverse --key 3 --numeric
end

# Get top pods based on mem
function kptm
    kubectl top pods -A | sort --reverse --key 4 --numeric
end

# Print limits and requests for pods
function kplr
    kubectl get pods -A -o=custom-columns='NAME:spec.containers[*].name,MEMREQ:spec.containers[*].resources.requests.memory,MEMLIM:spec.containers[*].resources.limits.memory,CPUREQ:spec.containers[*].resources.requests.cpu,CPULIM:spec.containers[*].resources.limits.cpu'
end

# Get internal IP addresses of cluster nodes
function knip
    kubectl get nodes -o json | jq -r '.items[].status.addresses[]? | select (.type == "InternalIP") | .address' | paste -sd "\n" -
end

# Get all unique container images across cluster
function kgca
    kubectl get pods --all-namespaces -o jsonpath="{.items[*].spec.containers[*].image}" | tr -s '[[:space:]]' '\n' | sort | uniq -c
end

function docker
    # Determine if containerd or docker is running
    set evalCmd (nerdctl info ^/dev/null && echo nerdctl || echo docker)
    set cntrCmd $evalCmd
    for var in $argv
        # strip docker from command
        if test $var = docker
            continue
        end
        # add each argument to the array
        set cntrCmd $cntrCmd $var
    end

    # execute the command with the arguments
    command $cntrCmd
end

function kdebug
    set POD $argv
    kubectl debug -it $POD --image=ubuntu:latest --image-pull-policy='Always' --profile=netadmin
end

function kdrun
    set IMAGE $argv
    set POD ephemeral-debug-(date -u +"%Y-%m-%dt%H-%M-%Sz")
    kubectl run $POD --image=$IMAGE --restart=Never --attach=true --image-pull-policy=Always --tty=true --privileged=true --rm=true --stdin=true --port=8080 -- /bin/bash
end

function awsprof
    if test -z "$argv"
        set AWS_PROFILE (perl -nle '/\[profile (.+)\]/ && print "$1"' < "$HOME/.aws/config" | fzf)
    else
        set AWS_PROFILE $argv
    end
    set -x AWS_PROFILE
end

function esanno
    set SECRET $argv
    kubectl annotate es $SECRET force-sync=(date +%s) --overwrite
end

function hbuild
    helm template base .
end

function htest
    helm template base . | kubeconform -schema-location default -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json' -strict -verbose
end

function kgfj
    kubectl get job --all-namespaces -o=jsonpath='{range .items[?(@.status.failed==1)]}{.metadata.namespace} {.metadata.name}{"\n"}{end}' | xargs -n 2 kubectl get job -n
end

function kdfj
    kubectl get job --all-namespaces -o=jsonpath='{range .items[?(@.status.failed==1)]}{.metadata.namespace} {.metadata.name}{"\n"}{end}' | xargs -n 2 kubectl delete job -n
end

function tf
    if test -f terragrunt.hcl
        terragrunt $argv
    else
        terraform $argv
    end
end

function git-check-ignore
    set FILE_PATH $argv
    git check-ignore -v $FILE_PATH
end

function tffmt
    terraform fmt -recursive && tf_vars_sort **/{outputs,variables}.tf(N) && terragrunt hclfmt
end

function flushdns
    sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder

    echo "Google Chrome:

    Open Chrome and type \"chrome://net-internals/#dns\" into the address bar.
    Press Enter to access the DNS page.
    Click on the \"Clear host cache\" button to clear the resolver cache.

Microsoft Edge (Chromium-based):

    Launch Edge and type \"edge://net-internals/#dns\" in the address bar.
    Press Enter to go to the DNS page.
    Click on the \"Clear host cache\" button to clear the resolver cache.

Mozilla Firefox:

    Open Firefox and type \"about:networking#dns\" in the address bar.
    Press Enter to access the DNS page.
    Click on the \"Clear DNS Cache\" button to clear the resolver cache.

Opera:

    Launch Opera and type \"opera://net-internals/#dns\" in the address bar.
    Press Enter to go to the DNS page.
    Click on the \"Clear host cache\" button to clear the resolver cache."
end

function start-grafana
    /opt/homebrew/opt/grafana/bin/grafana server --config /opt/homebrew/etc/grafana/grafana.ini --homepath /opt/homebrew/opt/grafana/share/grafana --packaging\=brew cfg:default.paths.logs\=/opt/homebrew/var/log/grafana cfg:default.paths.data\=/opt/homebrew/var/lib/grafana cfg:default.paths.plugins\=/opt/homebrew/var/lib/grafana/plugins
end

function jira
    # launch in a (subshell) so the api token doesn't linger in env after running
    begin
        set -x JIRA_API_TOKEN (jq -r '.api_token' "$JIRA_CONFIG_HOME"/jira-config.json)
        command jira $argv
    end
end

function ghpr
    # launch in a (subshell) so the api token doesn't linger in env after running
    begin
        set -x GITHUB_TOKEN (gh auth token -u wrightbradley)
        command uv run $HOME/bin/open-gh-pr.py $argv
    end
end

function ghcw
    command uv run $HOME/bin/create-worktree.py $argv
end

function ukctx
    kubectl config unset current-context
end

function ktn
    kubectl drain --ignore-daemonsets --delete-emptydir-data $argv
end

function oldman
    # source: https://media3.giphy.com/media/LvtKS6f1WatQ4/giphy-downsized.gif?cid=6104955ev42b150we7z0cd8shnoeh02cyopzgojz3uwzy5bn&ep=v1_gifs_translate&rid=giphy-downsized.gif&ct=g
    echo "https://tinyurl.com/3e63z8dz" | pbcopy
end

function wednesday
    # source: https://preview.redd.it/5n5dibawgvd61.jpg?width=960&height=831&crop=smart&auto=webp&s=a5afc53cdd81583a067d5a407a1ae8bdc42e58bd
    echo "https://tinyurl.com/cvbteam9" | pbcopy
end

function firedog
    echo "https://media3.giphy.com/media/v1.Y2lkPTYxMDQ5NTVla3VucmhoeWU0bG10ZDMyYjhnMmJnOXRhb3U4MGp2YW5mb3l4YmJ3aSZlcD12MV9naWZzX3RyYW5zbGF0ZSZjdD1n/QMHoU66sBXqqLqYvGO/giphy.gif" | pbcopy
end

function brewls
    # https://apple.stackexchange.com/a/438632
    brew info --json=v2 --installed | jq -r '.formulae[]|select(any(.installed[]; .installed_on_request)).full_name'
end

# function yy
#   set tmp (mktemp -t "yazi-cwd.XXXXXX")
#   yazi $argv --cwd-file=$tmp
#   if set cwd (cat -- $tmp) && test -n "$cwd" && test "$cwd" != "$PWD"
#     cd -- $cwd
#   end
#   rm -f -- $tmp
# end

# Snippets
# kubectl get pods -n apps -l app.kubernetes.io/name=app -o json | jq -r '.items[].metadata.name' | parallel -j 4 'echo {}; kubectl exec {} -- /bin/ash -c "ps -eo pid,etime,comm | grep python"'

# Temp workaround to disable punycode deprecation logging to stderr
alias cdktf='NODE_OPTIONS="--no-deprecation --max-old-space-size=4096" npx cdktf-cli'

# if test -f ~/.work-aliases
#     source ~/.work-aliases
# end

function secure_history
    gsed -i '/base64 --decode/d; /base64 --encode/d; /base64 -d/d; /base64 -e/d;' ~/.zsh_history
end

function pr_commits
    git log --date-order --pretty=format:"%C(bold yellow)%h%C(reset) %s%C(auto)%d%C(reset)%n  * %b" origin/main..HEAD | grep -v Signed-off-by | pbcopy
end

function ytdown
    set VIDEO $argv
    yt-dlp -f bestvideo+bestaudio/best --add-metadata -o "%(title)s.%(ext)s" --embed-chapters --merge-output-format mp4 --embed-thumbnail $VIDEO
end

function awswhoami
    aws sts get-caller-identity $argv
    aws iam list-account-aliases $argv
end

# Fuzzy-search a list of TLDR pages, starting with an optional query.
alias tldrf='tldr --list | fzf --reverse --preview "tldr --color always {1}" --preview-window=right,60% | xargs tldr --color always'
