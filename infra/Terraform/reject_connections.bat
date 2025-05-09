@echo off

for /f "delims=" %%i in ('aws ec2 describe-vpc-endpoint-connections --filters "Name=service-id,Values=%1" --query "VpcEndpointConnections[*].VpcEndpointId" --output text') do set VPC_ENDPOINTS=%%i

if not "%VPC_ENDPOINTS%"=="" (
    echo Rejecting VPC Endpoint Connections: %VPC_ENDPOINTS%
    aws ec2 reject-vpc-endpoint-connections --service-id %1 --vpc-endpoint-ids %VPC_ENDPOINTS%
    if errorlevel 1 (
        echo Error rejecting VPC endpoint connections.
        exit /b %errorlevel%
    )
) else (
    echo No VPC Endpoints to reject for service-id: %1
)

exit /b 0
