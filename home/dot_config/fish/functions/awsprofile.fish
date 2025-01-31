function awsprofile
    if count $argv >/dev/null
        set -gx AWS_PROFILE $argv
    else
        set -gx AWS_PROFILE "(perl -nle '/\[profile (.+)\]/ && print "$1"' < "$HOME/.aws/config" | sort | fzf)"
    end
end
