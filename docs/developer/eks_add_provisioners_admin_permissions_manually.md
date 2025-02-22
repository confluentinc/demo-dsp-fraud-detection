<details>
<summary>Navigate to the Kubernetes Cluster Access Panel & Update Access Type </summary>

1. Log into your AWS Console
2. Navigate to the correct Region
3. Navigate to the EKS Cluster Page
4. Select the appropriate Cluster
5. Select `Access` on the horizontal cluster menu
6. Select the `Manage Access` button
7. Select `EKS API and ConfigMap` option and then select `Save changes`; this will take ~5 minutes to update
</details>

<details>
<summary>Create IAM Access Entry</summary>

1. Navigate back to the `Access` panel on the horizontal cluster menu; The `IAM access entries` card will activate the `Create access entry` button when the above setting is updated, click the `Create access entry` (you may need to refresh the page)
2. In the `IAM Principal` dropdown select the [Admin user the AWS API key being used is configured with](#1-configure-aws-api-key)
3. In the `Type` dropdown select `Standard`
4. Click the `Next` button
5. In the `PolicyName` dropdown select `AmazonEKSAdminPolicy`
6. In the `Access Scope` select the `Cluster` radio button
7. Click the `Next` button
8. On the next page click the `Create` button
</details>

<details>
<summary>Add Access Policies to Created IAM Access Entry</summary>

1. Navigate back to the `Access` panel on the horizontal cluster menu
2. Click on the IAM Access Entry created in the [Create IAM Access Entry step](#create-iam-access-entry)
3. Scroll down to the `Access policies` card
4. Select `Add access policy` on the `Access policies` card
5. In the `PolicyName` dropdown select `AmazonEKSAdminPolicy`
6. In the `Access Scope` select the `Cluster` radio button
7. Click the `Add access policy` button
8. Repeat these steps for the `AmazonEKSClusterAdminPolicy`
</details>
