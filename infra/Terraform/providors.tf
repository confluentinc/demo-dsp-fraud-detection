terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "5.84"
        }
        confluent = {
          source  = "confluentinc/confluent"
          version = "2.12.0"
        }
        kubernetes = {
          source  = "hashicorp/kubernetes"
          version = "2.35.1"
        }
    }
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = aws_eks_cluster.eks_cluster.name
}

provider "kubernetes" {
  host                   = aws_eks_cluster.eks_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks_auth.token
}

# TODO: update to setup env variables and setup config in README
provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
  # dendpoint = var.confluent_cloud_api_endpoint
}

# https://docs.confluent.io/cloud/current/networking/peering/aws-peering.html
# Create a VPC Peering Connection to Confluent Cloud on AWS
# TODO: update to reference aws config and have section to setup config in README
provider "aws" {
  region = var.region
  access_key = var.aws_key
  secret_key = var.aws_secret
  shared_credentials_files = null
  shared_config_files = null

}
