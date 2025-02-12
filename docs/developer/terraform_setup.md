## Infrastructure
Create all necessary Infrastructure

## Prerequisites
 - [Create AWS Keypair](create_aws_keypair.md)

## Clear Releavnt Environment 
 - Clear relevant environment variables
    ```bash
       unset AWS_REGION
       unset AWS_ACCESS_KEY_ID
       unset AWS_SECRET_ACCESS_KEY
       unset AWS_SESSION_TOKEN
       unset AWS_ACCOUNT_ID
       unset AWS_PROFILE
    ```
 - Clear aws config file
    ```bash
    cp ~/.aws/credentials ~/.aws/credentials.bak
    > ~/.aws/credentials
   ```
 - Test aws config file is empty
   ```bash
   cat ~/.aws/credentials
   ```
 - Test aws backup config file generated correctly
   ```bash
   cat ~/.aws/credentials.bak
   ```



## TerraForm Setup
1. Init the resources to add a new provider (AWS, Confluent, etc.)
```bash
terraform -chdir=../../infra/Terraform init -upgrade
```

2. Validate the resources to check for syntax errors
```bash
terraform -chdir=../../infra/Terraform validate
```

3. Plan the resources (Apply Dry Run)
```bash
terraform -chdir=../../infra/Terraform plan
```

4. Apply the resources (Create relevant resources)
```bash
terraform -chdir=../../infra/Terraform apply # --auto-approve
```

4. Get outputs (
```bash
terraform -chdir=../../infra/Terraform output # resource-ids
```

## Terraform Takedown
1. Delete the resources
```bash
terraform -chdir=../../infra/Terraform destroy
```
