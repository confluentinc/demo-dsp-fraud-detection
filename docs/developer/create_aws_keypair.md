# How to Create and Upload an RSA Keypair as an AWS KeyPair Object

This guide provides step-by-step instructions to generate an RSA keypair and upload it to AWS as an AWS keypair object. All steps are completed using a macOS terminal.

## Prerequisites
 - [Install all prerequisite software](prerequisite_installations.md)
 - [Set relevant environment variables](get_and_set_environment_variables.md)

---

## 1. Create an RSA Keypair

### Step-by-step instructions:

1. Open your macOS terminal.
2. Use the `aws ec2 create-key-pair` command to generate a 2048-bit RSA keypair.

```bash
aws ec2 create-key-pair --key-name ${AWS_KEYPAIR_NAME} --query 'KeyMaterial' --output text > ~/.ssh/${AWS_KEYPAIR_NAME}.pem
```


### 2. Verify Local Key Creation:
```bash
# List the keypair files
ls -l ~/.ssh/${AWS_KEYPAIR_NAME}*
```

**Expected Output**:
```plaintext
-rw------- 1 user staff 1675 Oct 10 10:00 /Users/yourusername/.ssh/my-aws-keypair -rw-r--r-- 1 user staff 400 Oct 10 10:00 /Users/yourusername/.ssh/my-aws-keypair.pub
```


## 3. Verify Remote KeyPair Uploaded

### Bash Code:
```bash
# List all Key Pairs in AWS
aws ec2 describe-key-pairs --key-name "${AWS_KEYPAIR_NAME}"
```

**Expected Output**:
```json
{
    "KeyPairs": [
        {
            "KeyName": "MyKeyPair",
            "KeyPairId": "key-0abc123de456f7890",
            "KeyFingerprint": "XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX"
        }
    ]
}
```

## 4. Update [terraform.tfvars](../../infra/Terraform/terraform.tfvars) `key_name` variable to the same value as ${AWS_KEYPAIR_NAME}


## 5. Reapply terraform

---

## Summary of Steps:
1. Generate an RSA keypair.
2. Verify keypair uploaded locally.
3. Confirm the upload by listing all AWS KeyPairs.
4. Update terraform.tfvars `key_name` variable to the same value as ${AWS_KEYPAIR_NAME}
5. Reapply terraform

This process ensures your RSA keypair is securely created and available for use in AWS.
