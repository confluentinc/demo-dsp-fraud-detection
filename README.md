# Build a Fraud Detection Application with Private Oracle CDC Connector
Fraud detection is crucial for protecting the financial assets of individuals and organizations in an increasingly digital world, leveraging analytical technologies to identify and prevent unethical activities and costly consequences. As digital transactions become more common, the complexity of fraud schemes also increases, requiring sophisticated detection methods. Modern methods like integrating advanced analytical and artificial intelligence algorithms help in identifying complex fraudulent patterns within vast datasets. 

Private connectors are essential in this context, serving to connect an organization’s internal systems with external services and applications. They facilitate the secure flow of information from multiple sources, providing a comprehensive view for detecting fraud. Additionally, ensuring data transfers over secure channels help maintain data integrity and confidentiality, crucial for preventing data breaches and ensuring regulatory compliances. 

This demo demonstrates how financial institutions can capture fraud transactions in real-time without leaving the public internet by leveraging stream processing and private connectors. This approach enables the seamless and secure synchronization of data across systems, ensuring real-time detection and response to potential fraudulent activities. Through stream processing with Flink, transactions are joined, filtered, aggregated and analyzed in real time, while private connectors ensure that data flows securely between systems, offering a robust solution for modern fraud detection. This use case will cover key new Confluent features using a realistic application deployed on AWS.

## Demo Diagram
![architecture_diagram.png](img/architecture_diagram.png)
The Demo features real-time fraud detection capabilities consisting of:
- Backend/Frontend setup suitable for various real-world applications
- Oracle DB on a private internal network for production use cases
- Oracle DB CDC Fully Managed Connector that streams events triggered Database interactions
- Confluent Kafka Cluster to store, stream & manage transaction & fraud events
- Confluent Flink Compute Pool for real-time fraud detection based on transaction events deriving from the Oracle DB 
- OpenSearch Fully Managed Sink Connector to stream fraud events to a dashboard for the fraud team
- OpenSearch Instance to showcase dashboards for the fraud team's analysis and decision-making
---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Provision Infrastructure with Terraform](#provision-infrastructure-with-terraform)
3. [Validate Networking Infrastructure](#validate-networking-infrastructure)
4. [Oracle DB Configuration](#oracle-db-configuration)
5. [Setup Oracle DB CDC Fully Managed Connector V1](#setup-oracle-db-cdc-fully-managed-connector-v1)
6. [Update Kubernetes Cluster Access](#update-kubernetes-cluster-access)
7. [Setup Web Application & Simulate Transactions](#setup-web-application--simulate-transactions)
8. [Setup Flink Compute Queries for Real-Time Stream Processing](#setup-flink-compute-queries-for-real-time-stream-processing)
9. [Setup OpenSearch Sink Connector](#setup-opensearch-sink-connector)
10. [Setup Opensearch Dashboard](#setup-opensearch-dashboard)
11. [Conclusion](#conclusion)

---

## Prerequisites

<details>
<summary>Installing Homebrew</summary>

Homebrew is a package manager for macOS, necessary for installing Docker or other dependencies. Follow these steps to verify and install Homebrew:
1. Verify if Homebrew is installed by running:
   ```bash
   brew --version
   ```
   **Expected Output**:
   ```
   Homebrew X.X.X
   ```
2. If Homebrew is not installed, install it using the following command:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
3. Verify the installation:
   ```bash
   brew --version
   ```
   **Expected Output**:
   ```
   Homebrew X.X.X
   ```

</details>

<details>
<summary>Install Supporting Software</summary>
In this section we will install and validate all required software for the demo with the following command

1. Run the command to install AWS CLI using Homebrew:
   ```bash
   brew install awscli
   brew tap hashicorp/tap
   brew install hashicorp/tap/terraform
   brew install confluentinc/tap/cli
   brew install kubectl
   brew install jq
   ```


2. Verify the installation with the following command

   ```bash
   aws --version
   terraform -version
   confluent version
   kubectl version --client
   jq --version
   ```
   
   **Expected Output**:
   ```plaintext
   You should see version info for each program
   ```

</details>

<details>
<summary>Windows Jump Server Software Installation</summary>

A Jump server on the internal network is required to connect to the Oracle DB that will be on a private internal network; the following software will allow you to connect to this jump server.

Download this application called `Windows App` for your specific OS.

</details>

<details>
<summary id="create_aws_admin_api_key">Create AWS Admin API Key</summary>

AWS Admin API keys are required to provision the necessary AWS infrastructure.

1. Create a new AWS IAM User
2. Grant the User Admin Permissions
3. Create API Key associated with the admin user (this should return a key & secret)
4. Copy the API key & secret into a usable place 
**Note:** Copy the region being used as well; Ex: `us-east-1`
5. Run `aws configure` and enter the appropriate API Key, Secret, & Region when prompted. 
**Note:** Region should be the same region User was created in

</details>

<details>
<summary id="create_cc_api_key">Create Confluent Cloud API Keys</summary>
Confluent Cloud `Cloud resource management` API keys are required to provision the necessary Confluent Cloud infrastructure.

1. Log into Confluent
2. Open the sidebar menu and select `API keys`
3. Click `+ Add API key`
4. Associate API Key with `My account`
5. Select `Cloud resource management`
6. Create the API key and copy the Key & Secret into a usable place

</details>

---

## Provision Infrastructure with Terraform
Terraform is used to automatically provision and configure infrastructure for both AWS and CC. 

 >[!CAUTION]
 >If the pre-requisites are not completed correctly the following will fail!


<details>
<summary>Set Terraform Variables</summary>
Terraform is configured via a[terraform.tfvars file](./infra/Terraform/terraform.tfvars).

All variables in the table below must be set in the [terraform.tfvars file](./infra/Terraform/terraform.tfvars) in order for Terraform to provision the infrastructure.

> [!NOTE]
> `example_var_key_name="example_var_key_value"`

| Key Name                   |  Type  | Description                           | Required |
|:---------------------------|:------:|:--------------------------------------|---------:|
| confluent_cloud_api_key    | string | [Key From CC](#create_cc_api_key)     |     True |
| confluent_cloud_api_secret | string | [Secret From CC](#create_cc_api_key)  |     True |
| aws_key                    | string | [Key From AWS](#create_cc_api_key)    |     True |
| aws_secret                 | string | [Secret From AWS](#create_cc_api_key) |     True |


</details>

<details>
<summary>Initialize Terraform Providers</summary>
This step verifies your access to the cloud providers used by Terraform for infrastructure provisioning.

The following resources will be provisioned:

| Provider   |                Type                | Role                                                                           | Terraform File                                                             | Resource Name                      |
|:-----------|:----------------------------------:|:-------------------------------------------------------------------------------|:---------------------------------------------------------------------------|:-----------------------------------|
| AWS        |                VPC                 | Virtual Private Network for AWS Subnets                                        | [aws_networking.tf](./infra/Terraform/aws_networking.tf)                   | main                               |
| AWS        |           Private Subnet           | Network for private AWS resources                                              | [aws_networking.tf](./infra/Terraform/aws_networking.tf)                   | private_subnets                    |
| AWS        |           Public Subnet            | Network for public AWS resources                                               | [aws_networking.tf](./infra/Terraform/aws_networking.tf)                   | public_subnets                     |
| AWS        |          Internet Gateway          | Ask Ahmed Here                                                                 | [aws_networking.tf](./infra/Terraform/aws_networking.tf)                   | igw                                |
| AWS        |                EIP                 | Ask Ahmed Here                                                                 | [aws_networking.tf](./infra/Terraform/aws_networking.tf)                   | eip                                |
| AWS        |            NAT Gateway             | Ask Ahmed Here                                                                 | [aws_networking.tf](./infra/Terraform/aws_networking.tf)                   | natgw                              |
| AWS        |        Private Route Table         | Ask Ahmed Here                                                                 | [aws_networking.tf](./infra/Terraform/aws_networking.tf)                   | private_route_table                |
| AWS        |         Public Route Table         | Ask Ahmed here                                                                 | [aws_networking.tf](./infra/Terraform/aws_networking.tf)                   | public_route_table                 |
| AWS        |  Private Route Table Association   | Ask Ahmed Here                                                                 | [aws_networking.tf](./infra/Terraform/aws_networking.tf)                   | priv_subnet_associations           |
| AWS        |   Public Route Table Association   | Ask Ahmed Here                                                                 | [aws_networking.tf](./infra/Terraform/aws_networking.tf)                   | pub_subnet_associations            |
| AWS        |        Security Group Role         | Grant Access to Port 443                                                       | [aws_networking.tf](./infra/Terraform/aws_networking.tf)                   | self_ingress_443                   |
| AWS        |           Security Group           | Ask Ahmed Here                                                                 | [aws_networking.tf](./infra/Terraform/aws_networking.tf)                   | sg                                 |
| AWS        |            VPC Endpoint            | Allow Access to Private Subnet                                                 | [aws_networking.tf](./infra/Terraform/aws_networking.tf)                   | privatelink                        |
| AWS        |           Route53 Record           | Ask Ahmed Here                                                                 | [aws_networking.tf](./infra/Terraform/aws_networking.tf)                   | privatelink                        |
| AWS        |          DB Subnet Group           | Ask Ahmed here                                                                 | [aws_oracledb.tf](./infra/Terraform/aws_oracledb.tf)                       | db_subnet_group                    |
| AWS        |           Security Group           | Grant Ingress Access to DB Port 1521 & Global Egress                           | [aws_oracledb.tf](./infra/Terraform/aws_oracledb.tf)                       | db_sg                              |
| AWS        |           RDS Oracle DB            | Private DB containing transaction records                                      | [aws_oracledb.tf](./infra/Terraform/aws_oracledb.tf)                       | oracle_db                          |
| AWS        |                AMI                 | Image for Windows Jump Server                                                  | [aws_windows_jump_server.tf](./infra/Terraform/aws_windows_jump_server.tf) | windows                            |
| LOCAL      |            Local Script            | Create & Upload Key Pair for Windows Jump Server                               | [aws_windows_jump_server.tf](./infra/Terraform/aws_windows_jump_server.tf) | ec2_key_pair                       |
| AWS        |              Instance              | EC2 Instance running Jump Server Image                                         | [aws_windows_jump_server.tf](./infra/Terraform/aws_windows_jump_server.tf) | windows_instance                   |
| AWS        |           Secruity Group           | Grant Ingress to Port 3389 & Global Egress                                     | [aws_windows_jump_server.tf](./infra/Terraform/aws_windows_jump_server.tf) | windows_sg                         |
| AWS        |         OpenSearch Domain          | Create Opensearch Instance                                                     | [aws_opensearch.tf](./infra/Terraform/aws_opensearch.tf)                   | OpenSearch                         |
| AWS        |              IAM Role              | Unknown                                                                        | [aws_eks.tf](./infra/Terraform/aws_eks.tf)                                 | eks_cluster_role                   |
| AWS        |              IAM Role              | Unknown                                                                        | [aws_eks.tf](./infra/Terraform/aws_eks.tf)                                 | eks_node_role                      |
| AWS        |              IAM Role              | Unknown                                                                        | [aws_eks.tf](./infra/Terraform/aws_eks.tf)                                 | eks_pod_identity                   |
| AWS        |     IAM Role Policy Attachment     | Attach IAM role to policy                                                      | [aws_eks.tf](./infra/Terraform/aws_eks.tf)                                 | eks_cluster_role_policy            |
| AWS        |     IAM Role Policy Attachment     | Attach IAM role to policy                                                      | [aws_eks.tf](./infra/Terraform/aws_eks.tf)                                 | eks_node_role_policy               |
| AWS        |     IAM Role Policy Attachment     | Attach IAM role to policy                                                      | [aws_eks.tf](./infra/Terraform/aws_eks.tf)                                 | AMAZONEKS_CNI_Policy               |
| AWS        |     IAM Role Policy Attachment     | Attach IAM role to policy                                                      | [aws_eks.tf](./infra/Terraform/aws_eks.tf)                                 | AmazonEC2ContainerRegistryReadOnly |
| AWS        |     IAM Role Policy Attachment     | Attach IAM role to policy                                                      | [aws_eks.tf](./infra/Terraform/aws_eks.tf)                                 | s3_read_only                       |
| AWS        |     IAM Role Policy Attachment     | Attach IAM role to policy                                                      | [aws_eks.tf](./infra/Terraform/aws_eks.tf)                                 | ec2_read_only                      |
| AWS        |     IAM Role Policy Attachment     | Attach IAM role to policy                                                      | [aws_eks.tf](./infra/Terraform/aws_eks.tf)                                 | eks_cluster_role_policy            |
| AWS        |    EKS Pod Identity Association    | Unknown                                                                        | [aws_eks.tf](./infra/Terraform/aws_eks.tf)                                 | example                            |
| AWS        |            EKS Cluster             | Create the EKS Cluster                                                         | [aws_eks.tf](./infra/Terraform/aws_eks.tf)                                 | eks_cluster                        |
| AWS        |       Kubernetes Config Map        | Associate Permissions with EKS Cluster                                         | [aws_eks.tf](./infra/Terraform/aws_eks.tf)                                 | aws_auth                           |
| AWS        |           EKS Node Group           | Configure EKS Nodes in Cluster                                                 | [aws_eks.tf](./infra/Terraform/aws_eks.tf)                                 | eks_node_group                     |
| AWS        |             EKS Add On             | Add AWS Kube Proxy Add on to Cluster                                           | [aws_eks.tf](./infra/Terraform/aws_eks.tf)                                 | kube_proxy                         |
| AWS        |             EKS Add On             | Add AWS CoreDNS Add on to Cluster                                              | [aws_eks.tf](./infra/Terraform/aws_eks.tf)                                 | coredns                            | 
| AWS        |             EKS Add On             | Add AWS Pod Identity Add on to Cluster                                         | [aws_eks.tf](./infra/Terraform/aws_eks.tf)                                 | pod_identity                       | 
| AWS        |             EKS Add On             | Add AWS VPC CNI Add on to Cluster                                              | [aws_eks.tf](./infra/Terraform/aws_eks.tf)                                 | vpc_cni                            | 
| CC         |            Environment             | Create Environment in CC                                                       | [confluent.tf](./infra/Terraform/confluent.tf)                             | staging                            |
| CC         |           Kafka Cluster            | Create Kafka Cluster in CC                                                     | [confluent.tf](./infra/Terraform/confluent.tf)                             | cluster                            |
| CC         |      Private Link Attachment       | Allow Connection between AWS & CC Environment                                  | [confluent.tf](./infra/Terraform/confluent.tf)                             | pla                                |
| CC         | Private Link Attachment Connection | Connect CC Environment to AWS VPC Endpoint                                     | [confluent.tf](./infra/Terraform/confluent.tf)                             | plac                               |
| CC         |          Service Account           | Service Account to Manage CC Kafka Cluster                                     | [confluent.tf](./infra/Terraform/confluent.tf)                             | app-manager                        |
| CC         |            Role Binding            | Bind Admin Role to Service Account for CC Environment                          | [confluent.tf](./infra/Terraform/confluent.tf)                             | app-manager-kafka-cluster-admin    |
| CC         |      Schema Registry Cluster       | Provision Schema Registry for Kafka Cluster                                    | [confluent.tf](./infra/Terraform/confluent.tf)                             | sr                                 |
| CC         |              API Key               | API Key to Manage Schema Registry                                              | [confluent.tf](./infra/Terraform/confluent.tf)                             | schema-registry-api-key            |
| CC         |             DNS Record             | Create URL for CC Env for AWS Private Link                                     | [confluent.tf](./infra/Terraform/confluent.tf)                             | main                               |
| CC         |              Gateway               | Create Gateway to Connect CC Environment to AWS Region                         | [confluent.tf](./infra/Terraform/confluent.tf)                             | confluent_rds_gateway              |
| CC         |            Access Point            | Create Access Point to Connect CC Environment to RDS                           | [confluent.tf](./infra/Terraform/confluent.tf)                             | confluent_oracle_db_access_point   |
| CC         |         Flink Compute Pool         | Create A Flink Compute Pool for CC Environment                                 | [flink.tf](./infra/Terraform/flink.tf)                                     | flink_pool                         |
| CC         |            Flink Rgion             | Create Flink Region in AWS for flink cluster                                   | [flink.tf](./infra/Terraform/flink.tf)                                     | flink_region                       |
| Local      |            Kube Config             | Update local kubeconfig file with newly provisioned Kubernetes Cluster Details | [kubernetes_setup.tf](./infra/Terraform/kubernetes_setup.tf)               | kube_config                        | 
| Kubernetes |             Config Map             | Create Config Map for Deployment Configs/Secrets                               | [kubernetes_setup.tf](./infra/Terraform/kubernetes_setup.tf)               | fraud_demo_config                  | 
| Kubernetes |             Deployment             | Create Deployment to run UI                                                    | [kubernetes_setup.tf](./infra/Terraform/kubernetes_setup.tf)               | fraud_demo                         | 
| Kubernetes |              Service               | Create Service to connect Deployment to Web                                    | [kubernetes_setup.tf](./infra/Terraform/kubernetes_setup.tf)               | ui                                 | 



Run the following command from the same directory as the `README.md` file.

   ```bash
   terraform -chdir=infra/Terraform init
   ```

   **Expected Output:**
   ```text 
   Terraform has been successfully initialized!
   ```
</details>

<details>
<summary>Provision Infrastructure via Terraform</summary>

This step will provision all the necessary infrastructure.

The following steps will set up, connect, and synchronize the specified resources across the mentioned providers:

**Note:** For more info on how resources interact please see the [Demo Diagram](#demo-diagram)


#### Provisioning the Infrastructure
Run the following bash command from the directory containing the README.md file. This will start provisioning most of the demos required infrastructure.

**Note:** This step is API intensive and may take 20-30 minutes.

**Note:** If it fails initially rerun the apply; it will only take 5-7 minutes & will work the second time.
   
   ```bash
   terraform -chdir=infra/Terraform apply --auto-approve
   ```
   
   **Note:** Actual output will be different based on provisioned resources
   
   **Note:** This output can be regenerated without in ~30 seconds after it has been generated once
   
   **Note:** Manually configured Resources will require inputs based on this output - exclude the quotes
   
   **Note** This output will occur the first time; rerun the apply and it will succeed
   ```text
   │ Error: error waiting for Access Point "ap-4vw528" to provision: access point "ap-4vw528" provisioning status is "FAILED": 
   │ 
   │   with confluent_access_point.confluent_oracle_db_access_point,
   │   on confluent_outbound_privatelink.tf line 15, in resource "confluent_access_point" "confluent_oracle_db_access_point":
   │   15: resource "confluent_access_point" "confluent_oracle_db_access_point" {
   │ 
   ╵
   ```
   
   **Expected Approximate Output:**
   ```text
   confluent_environment_name = "frauddetectiondemo-environment-3912b8ae"
   opensearch_dashbaord_url = "https://search-frauddetectiondemo-3912b8ae-c4suntj5atq6d2bgeccuzok4dq.us-west-2.es.amazonaws.com/_dashboards"
   opensearch_endpoint = "https://search-frauddetectiondemo-3912b8ae-c4suntj5atq6d2bgeccuzok4dq.us-west-2.es.amazonaws.com"
   opensearch_password = "Admin123456!"
   opensearch_username = "admin"
   oracle_db_connection_string = "terraform-20250131031349887600000007.cy56rbcnrbof.us-west-2.rds.amazonaws.com:1521/DEMODB"
   oracle_db_dbname = "DEMODB"
   oracle_db_hostname = "terraform-20250131031349887600000007.cy56rbcnrbof.us-west-2.rds.amazonaws.com"
   oracle_db_password = "thebestpasswordever!"
   oracle_db_username = "thebestusername"
   resource-ids = <sensitive>
   windows_instance_ip = "54.214.225.66"
   windows_instance_password = "bLi%?aQ6JB=hG(Doz1h=AXtsl.6S0;6S"
   windows_instance_username = "Administrator"
   ```

</details>

---

## Validate Networking Infrastructure
In the next step we will validate that the networking between AWS & Confluent is working as expected.

<details>
<summary>Validate AWS Private Endpoint</summary>

![aws_endpoint_services.png](img/aws_endpoint_services.png)
1. Log into the AWS console
2. Enter `endpoint services` into the `search` textbox
3. Select the `endpoint services` feature button
4. You will see an entry in the list view; under the `State` column it should say active
5. You know the AWS Endpoint to view the Oracle DB state changes within the private network is correctly configured
</details>

<details>
<summary>Validate Confluent Private Egress & Ingress</summary>

![confluent_networking.png](img/confluent_networking.png)
1. Reopen the Windows Jump Server; this is the server setup in the [access the internal Windows machine section](#access-the-internal-windows-machine)
2. Log into [Confluent Cloud](https://confluent.cloud/login)
3. Select `Environments`
4. Select the environment named after the `confluent_environment_name` output from Terraform
5. In the horizontal menu select `Network Managment` 
6. In the list view you will see 2 entries 
   1. Each entries `Status` column will say `Ready`
   2. One entries `Direction` column will say `Egress`, the others will say `Ingress`
7. You know the Confluent Ingress/Egress to interact with AWS has been provisioned correctly
</details>

---

## Oracle DB Configuration

In order for the fully managed Oracle CDC Connector V1 to properly work with the Oracle DB provisioned via Terraform in AWS certain, Oracle DB settings must be configured.

The Oracle DB is configured on a private network within AWS, making it inaccessible from your local machine, and only accessibile from a machine within the private network.

This machine existing within the AWS private network has already been setup by Terraform and can be accessed using `Windows App` application that we downloaded in the [prerequisite software section](#4-windows-jump-server-software-installation).

<details>
<summary>Access Windows Machine in Internal Network</summary>

1. Open the `Windows App`![windows_app_view.png](img/windows_app_view.png)
2. Click the `+` Icon to add new Server Connection, Click `Add PC` from the dropdown menu
3. Enter `windows_instance_ip` value from Terraform outputs in the `PC name:` textbox
4. Click the `Credentials` dropdown menu, select `Add Credentials...`, A pop up menu will appear
5. Enter `windows_instance_username` value from Terraform outputs into the `Username:` text field
6. Enter `windows_instance_password` value from Terraform outputs into the `Password:` text field
7. Click the `Add` button in the bottom right of the credentials pop up 
8. Click the `Add` button in the bottom right of the instance pop up
9. Click the newly created pop up titled with the `windows_instance_ip`
10. You will be redirected to a Windows OS for the machine located the AWS Oracle DB network
</details>

<details>
<summary>Download Oracle DB Client Software on Internal Windows Machine</summary>

1. Open the web browser on the machine
2. Download your Database Tool of Choice (I prefer Pycharm) **Note:** Pycharm will automatically download Oracle JDK
3. Download Oracle JDK 
4. Open your DB tool
5. Connect to the DB 
</details>

<details>
<summary>Configure Oracle DB on Internal Windows machine</summary>

1. Run the following command to configure the Database

   ```oracdle
   begin
    rdsadmin.rdsadmin_util.alter_supplemental_logging(
        p_action => 'ADD',
        p_type   => 'ALL');
   end;
   ```
2. Validate the database is configured
   ```oracle
   SELECT log_mode FROM v$database;
   ```
   
   **Expected Output:**
   ```text
   LOG_MODE
   -------
   ARCHIVELOG
   ```
3. The database has now been configured.

**Note:** Minimize the window to the Internal Windows Machine it will be used later (you can always connect again if you already closed it)
</details>

---

## Setup Oracle DB CDC Fully Managed Connector V1

The following steps will result in database change events on the `DEMODB` database tables `USER_TRANSACTION` & `AUTH_USER` being streamed to Kafka topics `fd.USER_TRANSACTION` & `fd.AUTH_USER`

<details>
<summary>Navigate to Cluster Connectors</summary>

![confluent_cluster_ui_view.png](img/confluent_cluster_ui_view.png)
1. Log into [Confluent Cloud](https://confluent.cloud/login)
2. Select `Environments`
3. Select the environment named after the `confluent_environment_name` output from Terraform
4. Select the cluster named after the `confluent_cluster_name` output from Terraform
5. Select `Connectors` in the Cluster sidebar menu on the left
</details>

<details>
<summary>Create Oracle DB CDC Fully Managed Connector V1</summary>

![oracle_connector_tile.png](img/oracle_connector_tile.png)
1. Type `oracle cdc source premium` in the `search` text field
2. Select the `Oracle CDC Source Premium` tile (it will be the only tile)
3. Generate Connector API Key
   1. Select the `My account`tile 
   2. Click the `Generate API key and download` button **Note:** If you too many existing API keys this will fail; remove any unused keys if this occurs 
   3. Click the `Continue` button **Note:** These API keys dont need to be recorded & will automatically be assigned to the cluster 
![oracle_connector_api_key.png](img/oracle_connector_api_key.png) 
4. Fill in the relevant Oracle DB Fields![oracle_connector_db_configs.png](img/oracle_connector_db_configs.png)
   1. Enter `oracle_db_hostname` Terraform output into the `Oracle server`textbox
   2. Enter `oracle_db_port` Terraform output into the `Oracle port` textbox
   3. Enter `oracle_db_dbname` Terraform output into the `Oracle SID` textbox
   4. Leave `Oracle PDB`textbox empty
   5. Leave `Oracle Service` textbox empty
   6. Enter `oracle_db_username` Terraform output into `Oracle username` textbox
   7. Enter `oracle_db_password` Terraform output into `Oracle password` textbox
   8. Click the `Contineu` button on the bottom right
5. Configure Connector settings ![oracle_connector_configs.png](img/oracle_connector_configs.png)
   1. Enter `oracle_connector_table_inclusion_regex` Terraform output into `Table inclusion regex` textbox 
   2. Enter **fd.${tableName}** into `Topic name tempalte` textbox **Note:** the prefix **fd** can be changed but will be referenced later; you can use any character only prefix here
   3. Select `JSON_SR` on the `Output Kafka record key format` select dropdown
   4. Select `JSON_SR` on the `Output Kafka record value format` select dropdown
   5. Click the `Show advanced settings` dropdown arrow
   6. Select `best_fit_or_string` on the `Map NUMERIC values by precision and scale` select dropdown
   7. Click the `Continue` button
6. Configure Connector sizing
   1. Enter **2** into the `Tasks max` textbox
   2. Click the `Continue` button
7. Configure Connector Name
   1. Enter any name you like in the `Connector name` textbox **Note:** This name will not be used anywhere else
   2. Click the `Continue` button
8. Wait for the connector to initialize; this could take ~5 minutes; The connector tile will show `Running` status when it is ready **Note:** You may need to refresh the page to update the connector status
9. The Connector has now successfully been setup and database change events on the `DEMODB` database tables `USER_TRANSACTION` & `AUTH_USER` will automatically be recorded to Kafka topic `fd.USER_TRANSACTION` & `fd.AUTH_USER`
</details>

---

## Update Kubernetes Cluster Access
We need to allow our local computer to access the Kubernetes cluster via the AWS terminal

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

<details>
<summary>Validate Kubernetes Cluster Setup Terraform</summary>

1. Ensure that only one Kubernetes Cluster is being created
   ```bash
   export AWS_REGION="us-west-2" # set the correct AWS Region 
   aws eks list-clusters --region ${AWS_REGION} #
   ```
   **Expected Output:**
   
   Example of a successful output:
   ```text
   {
       "clusters": [
           "frauddetectiondemo-eks-cluster-<cluster-string-name>",
      ]
   }
   ```
   
   **Note:** You will need to press `ctrl c` after this is ran


2. Store the kubernetes cluster name so you can interact with it.
   ```bash
   export AWS_CLUSTER_NAME=$(aws eks list-clusters --region ${AWS_REGION} --output json | jq -r '.clusters[0]')
   echo $AWS_CLUSTER_NAME
   ```
   
   **Expected Output:**
   
   ```text
   frauddetectiondemo-eks-cluster-<cluster-string-name>
   ```
   
3. Update your local Kube config to enable `kubectl` command line client 
   ```bash
   aws eks --region ${AWS_REGION} update-kubeconfig --name ${AWS_CLUSTER_NAME}
   ```

   **Expected Output:**

   ```text
   Added new context arn:aws:eks:<region-name>:<account-id>:cluster/<cluster-name> to kubeconfig
   ```

4. Validate you can access the Pod
   ```bash
   kubectl get nodes
   ```
   
   **Expected Output:**
   ```text
   NAME STATUS ROLES AGE VERSION ip-192-168-1-1.ec2.internal Ready  15m v1.25.6 ip-192-168-2-1.ec2.internal Ready  15m v1.25.6
   ```
5. Set working namespace to default
   ```bash
   kubectl config set-context --current --namespace=default
   ```
   **Expected Output:**
   ```text
   Context "<current-context>" modified.
   ```
6. Validate namespace is set to default
   ```bash
   kubectl config view --minify | grep namespace:
   ```
   
   **Expected Output:**
   ```text
   namespace: default
   ```
7. Validate the web application is running
   ```bash
   export POD_LOGS=$(kubectl get pods --sort-by=.metadata.creationTimestamp \
     -o jsonpath='{.items[?(@.metadata.name contains "fraud-demo")].metadata.name}' | awk 'NR==1')
   echo $POD_LOGS
   kubectl get pods
   kubectl logs ${POD_LOGS}
   ```
   
   **Expected Output**
   ```text
   10.0.11.94 - - [03/Feb/2025:19:03:03 +0000] "GET /health/ HTTP/1.1" 200 16 "-" "kube-probe/1.31+"
   ```

</details>

---

## Setup Web Application & Simulate Transactions
Now that all the Infrastructure is provisioned and the database connector is provisioned and setup we can start creating real database transactions.


<details>
<summary>Connect to the Web UI</summary>

To connect to the Web UI and create transactions, we will need to port forward the pod connection to our localhost.

1. Port forward from Kubernetes Pod to LocalHost
   ```bash
   export POD_PORT_FORWARD=$(kubectl get pods --sort-by=.metadata.creationTimestamp \
    -o jsonpath='{.items[?(@.metadata.name contains "fraud-demo")].metadata.name}' | awk 'NR==1')
   echo $POD_PORT_FORWARD
   kubectl port-forward pod/${POD_PORT_FORWARD} 8000:8000
   ```

   **Expected Outputs:**
   ```text
   Forwarding from [::1]:8000 -> 8000
   ```
2. Open the Web UI by opening your webbrowser to [http://localhost:8000/fraud-demo/](http://localhost:8000/fraud-demo/)![transaction_ui.png](img/transaction_ui.png)
3. In the UI turn on the `Stream Real Transactions` toggle; after it is toggled every ~5 seconds a valid transaction will be created and its details will be visible in the `All Transactions` table
4. Allow 5-6 valid transactions to be created
5. In the Web UI `Simulate Fraud` dropdown select each option and click the `Commit Fraud` button 4 times. Each option to select
   - `Burst Count Transaction`
   - `Burst Amount Transaction`
   - `Large Amount Transaction`
   - `Foreign Transaction`

</details>

<details>
<summary>Validate Transaction Streamed to Topic via Connector </summary>

1. Log into [Confluent Cloud](https://confluent.cloud/login)
2. Select `Environments`
3. Select the environment named after the `confluent_environment_name` output from Terraform
4. Select the cluster named after the `confluent_cluster_name` output from Terraform
5. Select `Topics` in the Cluster sidebar menu on the left
6. Examine the `Topic name` table column; the prefix.AUTH_USER & prefix.USER_TRANSACTION will exist. **Note:** your prefix may differ based on how you configured the `table prefix` in the connector settings in step 5 of [setting up the Oracle DB CDC connector](#setup-oracle-db-cdc-fully-managed-connector-v1).
</details>

---

## Setup Flink Compute Queries for Real-Time Stream Processing
We will proceed to establish real-time stream processing of Kafka Topic events using Flink. These events are protected and only available within the private network; therefore, we will need to access the events from the internal windows jump server.

<details>
<summary>Navigate to Flink Via Internal Windows machine</summary>

1. Reopen the Windows Jump Server; this is the server setup in the [access the internal Windows machine section](#access-the-internal-windows-machine)
2. Log into [Confluent Cloud](https://confluent.cloud/login)
3. Select `Environments`
4. Select the environment named after the `confluent_environment_name` output from Terraform
5. In the horizontal menu select `Flink` ![flink_tab_menu.png](img/flink_tab_menu.png)
6. Select `Open SQL workspace`
</details>

<details>
<summary>Validate Flink has access to Oracle DB Connector Generated Events</summary>

1. In the Flink SQL Query Text Card enter **Note:** your prefix may differ based on how you configured the `table prefix` in the connector settings in step 5 of [setting up the Oracle DB CDC connector](#setup-oracle-db-cdc-fully-managed-connector-v1).
   ```oracle
   SELECT * FROM `prefix.AUTH_USER`;
   ```
2. Click the `Run` button below the bottom right of the Flink SQL Query Text Card and results will populate.
3. Click the `+` icon to the left of the Flink SQL Query Text Card to create a new SQL Query Text Card.
4. In the new Flink SQL Query Text Card enter **Note:** your prefix may differ based on how you configured the `table prefix` in the connector settings in step 5 of [setting up the Oracle DB CDC connector](#setup-oracle-db-cdc-fully-managed-connector-v1).
   ```oracle
    SELECT * FROM `prefix.USER_TRANSACTION`;
   ```
   ![user_transaction_flink_query.png](img/user_transaction_flink_query.png)
5. Click the `Run` button below the bottom right of the Flink SQL Query Text Card and results will populate.
</details>

<details>
<summary>Update the User Transaction table watermark to allow Timestamp based operations </summary>

1. Click `+` Icon to the left of the Flink SQL Query Text Card to create a new query card
2. In the new Flink SQL Query Text Card enter **Note:** the environment and cluster name will change based on the terraform output vars; the prefix will change as well based on what you determined it to be.
   ```oracle
   ALTER TABLE `terraform_output_confluent_environment_name`.`terraform_output_confluent_cluster_name`.`prefix.USER_TRANSACTION` 
       MODIFY WATERMARK FOR `RECEIVED_AT` AS `RECEIVED_AT`;
   ```
3. Click the `Run` button below the bottom right of the Flink SQL Query Text Card and results will pop up
![update_watermark_flink_query.png](img/update_watermark_flink_query.png)
</details>

<details>
<summary>Process Transaction Events In Real Time with Flink</summary>

1. Click `+` Icon to the left of the Flink SQL Query Text Card to create a new query card
2. In the new Flink SQL Query Text Card enter 

   **Note:** Record the name the table is set to (in this case it would be `flagged_user`); 
   **Note:** this query references the tables we validated in the previous steps, ensure you reference them correctly
   **Note:** If you do not do this step correctly data generated will force you rename the `flagged-user-materializer` to `flagged-user<attempt#>-materializer` & the flagged_user table (in `CREATE TABLE`) to `flagged_user<attempt#>`
   

   ```oracle
   SET 'client.statement-name' = 'flagged-user-materializer';
   CREATE TABLE flagged_user (
     ACCOUNT_ID BIGINT, 
     user_name STRING,
     email STRING,
     total_amount DOUBLE,
     transaction_count BIGINT,
     updated_at TIMESTAMP_LTZ(3),
     PRIMARY KEY (ACCOUNT_ID) NOT ENFORCED
   )
   AS 
   WITH transactions_per_customer_10m AS 
   (
     SELECT 
       ACCOUNT_ID,
       SUM(AMOUNT) OVER w AS total_amount,
       COUNT(*) OVER w AS transaction_count,
       RECEIVED_AT AS transaction_time
     FROM `test.USER_TRANSACTION`
     WINDOW w AS (
       PARTITION BY ACCOUNT_ID
       ORDER BY RECEIVED_AT
       RANGE BETWEEN INTERVAL '10' MINUTE PRECEDING AND CURRENT ROW
     )
   ) 
   SELECT 
     COALESCE(ACCOUNT_ID, 0) AS ACCOUNT_ID,
     u.USERNAME AS user_name,
     u.EMAIL AS email,
     transanactions.total_amount,
     transanactions.transaction_count,
     transanactions.transaction_time AS updated_at
   FROM 
     transactions_per_customer_10m AS transanactions
   JOIN `test.AUTH_USER` AS u 
     ON transanactions.ACCOUNT_ID = u.`key`
   WHERE 
     transanactions.total_amount > 1000 OR transanactions.transaction_count > 10;
   ```
3. Click the `Run` button below the bottom right of the Flink SQL Query Text Card and results will pop up
</details>

<details>
<summary>Validate Flink Generated Fraud Detection Topic</summary>

1. Click `+` Icon to the left of the Flink SQL Query Text Card to create a new query card
2. In the new Flink SQL Query Text Card enter 
   ```oracle
   SELECT * FROM `flagged_user`;
   ```
3. Click the `Run` button below the bottom right of the Flink SQL Query Text Card and results will pop up
![flagged_user_flink_query.png](img/flagged_user_flink_query.png)

**Note:** This will create a kafka topic named `flagged_user` which can be seen from the Kafka Cluster view as well.
</details>

<details>
<summary>Test Real Time Fraud Detection</summary>

1. [Open the fraud UI](#connect-to-the-web-ui) **Note:** if the port forwarding is still running in the terminal it won't need to be port forwarded again.
2. In the Web UI `Simulate Fraud` dropdown select the `Burst Count Transaction` option and click the `Commit Fraud` button 4 times. 
3. Navigate back to the `flagged_user` Flink SQL Query Card output setup in the [Test newly created fraud detection section](#test-the-newly-created-fraud-detection-table) & you will see fraud events generated (these can be validated via the `username` field)
</details>

---

## Setup OpenSearch Sink Connector
We will now stream the real-time fraud Kafka events generated through the Flink query to a dashboard for the fraud team's analysis.

<details>
<summary>Navigate to Confluent Cluster Connector View</summary>

1. Log into [Confluent Cloud](https://confluent.cloud/login)
2. Select `Environments`
3. Select the environment named after the `confluent_environment_name` output from Terraform
4. Select the cluster named after the `confluent_cluster_name` output from Terraform
5. Select `Connectors` in the Cluster sidebar menu on the left
6. Click `+ add connector` button in top right of the view
</details>

<details>
<summary>Create OpenSearch Sink Connector</summary>

1. Type `opensearch sink` in the `search` text field
2. Select the `OpenSearch Sink` tile (it will be the only tile)
3. Select `flagged_user` checkbox in the Topics table![opensearch_sink_topic_selected.png](img/opensearch_sink_topic_selected.png)
4. Click the `Continue` button in the bottom right
5. Generate Connector API Key
   1. Select the `My account`tile 
   2. Click the `Generate API key and download` button **Note:** If you too many existing API keys this will fail; remove any unused keys if this occurs 
   3. Click the `Continue` button **Note:** These API keys dont need to be recorded & will automatically be assigned to the cluster
6. Configure Connector Authentication settings ![opensearch_auth_settings.png](img/opensearch_auth_settings.png)
   1. Enter `opensearch_endpoint` Terraform output into `OpenSearch Instance URL` textbox 
   2. Select `BASIC` on the `Endpoint Authentication Type` dropdown
   3. Enter `opensearch_username` Terraform output into `Auth Username` textbox
   4. Enter `opensearch_password` Terraform output into `Auth Password` textbox
   5. Select `false` on the `SSL_Enabled` dropdown
   6. Click the `Continue` button
7. Configure Connector Topic & Index settings![opensearch_topic_mapping.png](img/opensearch_topic_mapping.png)
   1. Select `ARVO` option in the `Input Kafka record value format` horizontal selection
   2. Select `1` in `Number of indexes` select dropdown
   3. Enter `flagged_user` in only `index` textbox
   4. Enter `flagged_user` in only `topic` textbox **Note:** This should be the name of the table you [created with the flink detection sql query](#create-real-time-flink-processing-to-identify-fraudulent-events)
   5. Select `IGNORE` in the `Behavior for null valued records` dropdown
   6. Select `1` in the `Batch size` dropdown
   7. Click the `Continue` button
8. Click the `Continue` button on the next page
9. Click the `Continue` button on the next page
10. You will now be on the Connectors UI page seeing a tile that is provisioning the OpenSearch Connector
11. Wait for the Connector to initialize; it will take ~5 minutes and you may have to refresh the page
</details>

---

## Setup Opensearch Dashboard

<details>
<summary>Log into OpenSearch</summary>

1. Go to URL from the Terraform output `opensearch_dashbaord_url`
2. Log into Opensearch using the Terraform outputs `opensearch_password` & `opensearch_username`
3. Click out of any modal pop-ups
</details>

<details>
<summary>Create Dashboard for Users Flagged With Fraud</summary>

1. Select the side menu from the 3 horizontal lines icon in the top right
2. Select `Dashbaord Management` > `Dashboard Managment` **Note:** If this is not available in the menu create a empty dashboard and try again.
3. Click `Saved Objects` menu option on the vertical menu on the right
4. Select `Import` on the top right
5. Select `Import` and select the `fraud_dashboard.ndjson` [filepath](/dashboards/fraud_dashboard.ndjson) 
6. Wait for it to import 
</details>

<details>
<summary>View Dashboard for Users Flagged With Fraud</summary>

1. Select the side menu from the 3 horizontal lines icon in the top right
2. Select `OpenSearch Dashboard` > `Dashboards`
3. Select `Fraud Dashboard` from the list view
4. You can see dashboards describing fraud events determined via flink in real-time
</details>

<details>
<summary>Generate Real & Fraudulent transactions and view them in the fraud dashboard</summary>

![opensearch_dashboard.png](img/opensearch_dashboard.png)
1. [Open the fraud UI](#connect-to-the-web-ui) **Note:** if the port forwarding is still running in the terminal it won't need to be port forwarded again.
2. In the UI turn on the `Stream Real Transactions` toggle; after it is toggled every ~5 seconds a valid transaction will be created and its details will be visible in the `All Transactions` table
3. Take note of the latest usernames from these transactions; they won't show up in the fraud dashboard
4. In the Web UI `Simulate Fraud` dropdown select the `Burst Count Transaction` option and click the `Commit Fraud` button 4 times. 
5. Take note of the 4 usernames correlated with these fraud events in the `All Transactions` table; they will be visible in the OpenSearch Fraud Dashboard
6. Navigate back to the Fraud Dashboard created in the [View the Dashboard for Flagged Users section](#view-the-dashboard-for-flagged-users); You will see the 4 usernames noted in step 5 of this section.

</details>

---

## Conclusion
Congratulations! You have successfully deployed real-time fraud detection employing an Oracle DB on a private network, utilizing Confluent's Private Link, fully managed connectors, fully managed Kafka streams, and Opensearch dashboards.

This use case demonstrates the advanced and proactive approach financial institutions can adopt to combat fraud effectively. By integrating stream processing with private connectors, they can drive real-time monitoring and detection capabilities, ensuring secure and seamless transaction processing. 

Feel free to leverage and update this demo to work for your specific use case long term.
