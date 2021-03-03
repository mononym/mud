#!/usr/bin/env bash

# install pip
OS=`cat /etc/os-release | grep '^NAME=' |  tr -d \" | sed 's/\n//g' | sed 's/NAME=//g'`

if [ "$OS" == "Ubuntu" ]; then
    apt-get -y update
    apt-get -y install python-pip
elif [ "$OS" == "Amazon Linux AMI" ]; then
    yum update -y 
    yum install -y python-pip
fi

# install aws-cli
pip install --upgrade pip &> /dev/null
pip install awscli --ignore-installed six &> /dev/null

# add boot script which loads environment variables
cat > /etc/profile.d/export_instance_tags.sh << 'EOF'
    # fetch instance info
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    REGION=$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)

    # export instance tags
    export_statement=$(aws ec2 describe-tags --region "$REGION" \
                            --filters "Name=resource-id,Values=$INSTANCE_ID" \
                            --query 'Tags[?!contains(Key, `:`)].[Key,Value]' \
                            --output text | \
                            sed -E 's/^([^\s\t]+)[\s\t]+([^\n]+)$/export \1="\2"/g')
    eval $export_statement

    # export instance info
    export INSTANCE_ID
    export REGION
EOF