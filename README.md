# Real Time Fraud Detection With Confluent Cloud
This demo will enable you to provision and test **real time** fraud detection using Private DB Connectors, Kafka event streams & real time Flink processing all easily orchestrated on Confluent Cloud. 

Fraud detection is crucial for protecting the financial assets of individuals and organizations in an increasingly digital world, leveraging analytical technologies to identify and prevent unethical activities and costly consequences. As digital transactions become more common, the complexity of fraud schemes also increases, requiring sophisticated detection methods. Modern methods like integrating advanced analytical and artificial intelligence algorithms help in identifying complex fraudulent patterns within vast datasets. 

This demo demonstrates how financial institutions can capture fraudulent transactions in real-time from databases that are on secure internal private networks by leveraging stream processing and private connectors.Through stream processing with Flink, transactions are joined, filtered, aggregated and analyzed in real time, while private connectors ensure that data flows securely between systems, offering a robust solution for modern fraud detection.

## Demo Diagram
![architecture_diagram.png](img/architecture.png)
The Demo was built to reflect a typical software production environment. It contains many common components such as:
- An EKS Kubernetes cluster hosts an app that can be accessed via the web
- An Oracle DB on a private internal network; no production database is publicly accessible

Real-Time fraud detection is achieved by adding a few more components:
- A Kafka Cluster to store, stream & manage transaction & fraud events
- An Oracle XStream Connector to stream database entries as Kafka events privately into a Kafka cluster hosted on Confluent Cloud
- A Flink Compute Pool to enrich transaction events from Oracle and morph them into data products for real-time fraud analysis 
- A Redshift Instance and Redshift Fully Managed Sink Connector to stream authentication and user transaction events for storage
- An OpenSearch Instance and OpenSearch Fully Managed Sink Connector to stream fraud events into dashboards for analysis and decision-making
---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Provision Infrastructure with Terraform](#provision-infrastructure-with-terraform)
3. [Labs](#labs)
4. [Clean-Up](#clean-up)
---

## Prerequisites

### Install Supporting Software
In this section we will install and validate all required software for the demo with the following command

1. Run the command to install AWS CLI using Homebrew:
   ```bash
   brew install awscli
   brew tap hashicorp/tap
   brew install hashicorp/tap/terraform
   brew install confluentinc/tap/cli
   brew install kubectl
   ```


2. Verify the installation with the following command

   ```bash
   aws --version
   terraform -version
   confluent version
   kubectl version --client
   ```

### Create AWS API Key

AWS API keys will be provisioned and provided to users on the day of the workshop. 

### Create Confluent Cloud API Keys

Confluent Cloud `Cloud resource management` API keys are required to provision the necessary Confluent Cloud infrastructure.
</summary><details>

1. Log into Confluent Cloud
2. Open the sidebar menu and select `API keys`
3. Click `+ Add API key`
4. Associate API Key with `My account`
5. Select `Cloud resource management`
6. Create the API key and copy the Key & Secret into a usable place
</details>   

### Install Windows Jump Server 

A Jump server on the internal network is required to connect to the Oracle DB that will be on a private internal network; the following software will allow you to connect to this jump server. Download this application called `Windows App` for your specific OS. 

---

## Provision Infrastructure with Terraform
Terraform is used to automatically provision and configure infrastructure for both AWS and CC. 

 >[!CAUTION]
 >If the pre-requisites are not completed correctly the following will fail!


### Set Terraform Variables
Terraform is configured via a terraform.tfvars file that users will create manually.

All variables in the table below must be set in the terraform.tfvars file in order for Terraform to provision the infrastructure.

| Key Name                   |  Type  | Description                           | Required |
|:---------------------------|:------:|:--------------------------------------|---------:|
| confluent_cloud_api_key    | string | [Key From CC](#create_cc_api_key)     |     True |
| confluent_cloud_api_secret | string | [Secret From CC](#create_cc_api_key)  |     True |


### Provision Infrastructure via Terraform

This step will provision all the necessary infrastructure, which may take up to 40 minutes.

Run the following commands from the same directory as the `README.md` file in order to initialize and apply Terraform.

   ```bash
   terraform -chdir=infra/Terraform init
   ```
   
   ```bash
   terraform -chdir=infra/Terraform apply --auto-approve
   ```

If it fails initially rerun the apply; it will only take 5-7 minutes & will work the second time.   

   ```text
   │ Error: error waiting for Access Point "abc123" to provision: access point "abc123" provisioning status is "FAILED": 
   │ 
   │   with confluent_access_point.confluent_oracle_db_access_point,
   │   on confluent_outbound_privatelink.tf line 15, in resource "confluent_access_point" "confluent_oracle_db_access_point":
   │   15: resource "confluent_access_point" "confluent_oracle_db_access_point" {
   │ 
   ╵
   ```

---
### Access The Internal Windows Machine

The Oracle DB is configured on a private network within AWS, making it inaccessible from your local machine, and only accessibile from a machine within the private network.

This machine existing within the AWS private network has already been setup by Terraform and can be accessed using `Windows App` application that we downloaded earlier.

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
---
## Labs

There are two labs to demonstrate two different use cases with Confluent Cloud. 
1. [Lab 1](./LAB1/LAB1-README.md) shows the path to migration from legacy systems like Oracle to modern data warehouses like Redshift by leveraging Confluent Cloud fully managed connectors. User authentication and transaction events will be streamed from a Fraud Detection website. 
2. [Lab 2](./LAB2/LAB2-README.md) showcases developing stream processing applications like filters, aggregations and joins in real-time with Flink and sending the newly enriched fraud data into OpenSearch dashboards or other analytics applications. 

---
## Clean-up
Once you are finished with this demo, remember to destroy the resources you created, to avoid incurring charges. You can always spin it up again anytime you want.

Before tearing down the infrastructure, delete the Oracle XStream, Redshift and OpenSearch connectors, as they were created outside of Terraform and won't be automatically removed:

```
confluent connect cluster delete <CONNECTOR_ID> --cluster <CLUSTER_ID> --environment <ENVIRONMENT_ID> --force
```

To destroy all the resources created run the command below from the ```terraform``` directory:

```
terraform -chdir=infra/Terraform destroy --auto-approve
```

