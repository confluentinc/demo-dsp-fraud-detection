# Tutorial: Retrieve and Set AWS Access Keys from Okta SSO

This guide provides step-by-step instructions on how to get and set AWS access keys using the Okta SSO URL: [https://confluent.okta.com/home/amazon_aws_sso/0oapre5uexO4fmlqX357/aln1ghfn5xxV7ZPbE1d8](https://confluent.okta.com/home/amazon_aws_sso/0oapre5uexO4fmlqX357/aln1ghfn5xxV7ZPbE1d8).

### Prerequisites
- **AWS CLI** installed on your system.
- Access to the Okta SSO URL provided above.
- Proper permissions to log in and retrieve credentials.

---

## Step 1: Log in to Okta SSO

1. Open your browser and visit:  
   [https://confluent.okta.com/home/amazon_aws_sso/0oapre5uexO4fmlqX357/aln1ghfn5xxV7ZPbE1d8](https://confluent.okta.com/home/amazon_aws_sso/0oapre5uexO4fmlqX357/aln1ghfn5xxV7ZPbE1d8)

2. Log in with your Okta username and password. Use MFA (Multi-Factor Authentication) if prompted.

3. Once logged in, select the account and role for which you want to retrieve credentials.

---

## Step 2: Retrieve Temporary AWS Credentials

Follow these steps to retrieve the credentials:

1. Once in the Okta AWS Management Console:
   - Navigate to **"AWS IAM Console"**.
   - Select a specific **IAM Role** if multiple roles are available.
   - Click **"Command line or programmatic access"** to retrieve temporary credentials.

2. Copy the provided:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_SESSION_TOKEN` (if available)

---

## Step 3: Set AWS Credentials on Your Machine

Set the AWS credentials as environment variables so the AWS CLI can use them. Use the following commands in your macOS terminal:

```bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
export AWS_SESSION_TOKEN="YOUR_SESSION_TOKEN" # Optional, include if provided.
```

**Example**:
```bash
export AWS_ACCESS_KEY_ID="AKIAYOURACCESSKEY"
export AWS_SECRET_ACCESS_KEY="YOURSECRETACCESSKEY123"
export AWS_SESSION_TOKEN="YOURSESSIONTOKEN123EXAMPLE"
```

---

## Step 4: Set All Other Relevant Variables

Other Environment Variables to Set.


```bash
export AWS_ACCOUNT_ID="550017254839"
export AWS_REGION="us-west-2"
export AWS_ACCESS_KEY_ID="AKIAYAD4VIW3ZJ5W52HI"
export AWS_SECRET_ACCESS_KEY="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"
export AWS_KEYPAIR_NAME="spencer-aws-keypair"
export AWS_ROLE_NAME=$(aws sts get-caller-identity --query "Arn" --output text | cut -d'/' -f2)
export AWS_CLUSTER_NAME=$(aws eks list-clusters --region ${AWS_REGION} --output json | jq -r '.clusters[0]')


export DOCKER_IMAGE_NAME="fraud-webapp"
export DOCKER_IMAGE_TAG="latest"
export DOCKER_REPO_NAMESPACE="demo"

export PRIVATE_DOCKER_HOST_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
export PRIVATE_DOCKER_REPO_URL="${PRIVATE_DOCKER_HOST_URL}/${DOCKER_REPO_NAMESPACE}"
export PRIVATE_DOCKER_IMAGE_URL="${PRIVATE_DOCKER_REPO_URL}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"

export PUBLIC_DOCKER_HOST_URL="public.ecr.aws/v3a9u0p7"
export PUBLIC_DOCKER_REPO_URL="${PUBLIC_DOCKER_HOST_URL}/${DOCKER_REPO_NAMESPACE}"
export PUBLIC_DOCKER_IMAGE_URL="${PUBLIC_DOCKER_REPO_URL}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
```

Test All Variables Set Correctly

 ```bash
 echo $DOCKER_IMAGE_NAME
 echo $DOCKER_IMAGE_TAG
 echo $DOCKER_REPO_NAMESPACE
 
 echo $PRIVATE_DOCKER_REPO_URL
 echo $PRIVATE_DOCKER_IMAGE_URL
 
 echo $AWS_ACCOUNT_ID
 echo $AWS_REGION
 echo $AWS_ACCESS_KEY_ID
 echo $AWS_SECRET_ACCESS_KEY
 echo $AWS_SESSION_TOKEN
 ```

## Step 5: Verify the AWS Credentials

Run the following command to verify that the credentials are correctly set and working:

```bash
aws sts get-caller-identity
```

**Expected Output**:
You should see output similar to:

```json
{
    "UserId": "AIDXXXXXXXXXXXXXX",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/test-user"
}
```

If you encounter issues, ensure that you correctly copied and set the values for your credentials.

---

## Step 6: Use the AWS CLI with Temporary Credentials

With the credentials set, you can now use the AWS CLI to perform operations. For example:

```bash
aws s3 ls
```

This will list all the S3 buckets in your account.

**Expected Output**:
```plaintext
2023-10-12 14:21:34 my-example-bucket
2023-10-12 15:15:42 another-bucket-name
```

---

## Step 6: Clear Temporary Credentials

Once you're done with your tasks, clear the environment variables to avoid unauthorized access:

```bash
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
```

---

## Additional Notes

- Temporary credentials usually expire after a short period (e.g., 1 hour). Repeat the steps above if your credentials expire.
- If you repeatedly use this method, consider configuring **Okta integration** with the AWS CLI for SSO-based authentication.

---

You have now successfully retrieved and set AWS access keys using the Okta SSO URL.