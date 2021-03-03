#!/usr/bin/env bash

getInstanceTags () {
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
    EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"

    # Print tags as 'export TAG_Key="Value"'
    aws ec2 describe-tags --region $EC2_REGION --filters "Name=resource-id,Values=$INSTANCE_ID" | \
      python -c "import sys,json; map(lambda t: sys.stdout.write('export TAG_%s=\"%s\"\n' % (t['Key'], t['Value'])), json.load(sys.stdin)['Tags'])"
}

# Export variables from tags
$(getInstanceTags)