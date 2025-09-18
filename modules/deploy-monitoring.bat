@echo off
echo Deploying monitoring and logging configuration...

echo.
echo Step 1: Initialize Terraform (if needed)
terraform init

echo.
echo Step 2: Plan the monitoring deployment
terraform plan -var="alert_email=maryakussah123@gmail.com"

echo.
echo Step 3: Apply the monitoring configuration
echo WARNING: This will update your existing infrastructure with monitoring capabilities.
set /p confirm="Do you want to continue? (y/N): "
if /i "%confirm%"=="y" (
    terraform apply -var="alert_email=maryakussah123@gmail.com" -auto-approve
    echo.
    echo Monitoring deployment completed!
    echo.
    echo Next steps:
    echo 1. Check your email and confirm the SNS subscription
    echo 2. View CloudWatch logs at: https://console.aws.amazon.com/cloudwatch/home
    echo 3. Monitor alarms at: https://console.aws.amazon.com/cloudwatch/home#alarmsV2:
) else (
    echo Deployment cancelled.
)

pause