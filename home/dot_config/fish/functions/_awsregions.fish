function _awsregions
    if test -n $AWS_PROFILE
        set -l regions (aws ec2 describe-regions --query 'Regions[].[RegionName]' --output text 2>/dev/null)
        if test $status -eq 0
            echo $regions
            return
        end
    end

    # NOTE: these are only regions that are enabled by default and to not require
    # an opt-in
    # https://docs.aws.amazon.com/global-infrastructure/latest/regions/aws-regions.html
    echo 'us-east-1
us-east-2
us-west-1
us-west-2
ap-south-1
ap-northeast-3
ap-northeast-2
ap-southeast-1
ap-southeast-2
ap-northeast-1
ca-central-1
eu-central-1
eu-west-1
eu-west-2
eu-west-3
eu-north-1
sa-east-1'
end
