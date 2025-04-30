function awsregion
    if test -n "$argv[1]"
        set -gx AWS_REGION $argv[1]
        return
    end

    if test -n $AWS_PROFILE
        set -l regions (aws ec2 describe-regions --query 'Regions[].[RegionName]' --output text 2>/dev/null)
        if test $status -eq 0
            echo $regions | fzf | read -gx AWS_REGION
            return
        end
    end

    _awsregions | fzf | read -gx AWS_REGION
end
