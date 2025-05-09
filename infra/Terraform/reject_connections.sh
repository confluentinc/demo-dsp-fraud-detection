#!/usr/bin/env sh

VPC_ENDPOINTS=$(aws ec2 describe-vpc-endpoint-connections --service-id $1 \
    --query 'VpcEndpointConnections[*].VpcEndpointId' --output text)

if [ ! -z "$VPC_ENDPOINTS" ]; then
    aws ec2 reject-vpc-endpoint-connections --service-id $1 --vpc-endpoint-ids $VPC_ENDPOINTS
else
    echo "No VPC Endpoints to reject"
fi
