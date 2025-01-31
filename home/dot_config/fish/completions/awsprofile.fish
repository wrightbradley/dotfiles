complete --command awsprofile --no-files
complete --command awsprofile --arguments "$(perl -nle '/\[profile (.+)\]/ && print "$1"' < "$HOME/.aws/config" | sort)"
