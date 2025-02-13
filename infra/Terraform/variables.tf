variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)."
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret."
  type        = string
  sensitive   = true
}

variable "aws_key" {
  description = "AWS API Key (with Lmabda Invoke Permission)."
  type        = string
}

variable "aws_secret" {
  description = "AWS API Secret."
  type        = string
  sensitive   = true
}

variable "aws_local_admin_service_account_name" {
  description = "AWS Local Admin Service Account Name."
  type        = string
  default     = "spencer"
}

# variable "aws_session" {
#   description = "AWS Session Token."
#   type        = string
#   sensitive   = true
# }

variable "region" {
  description = "The region of Confluent Cloud Network; If this is changed `availability_zones` variable must also be changed"
  type        = string
  default     = "us-west-2"
}

variable "availability_zones" {
  description = "List of availability zones to use for the private subnets"
  type        = list(string)
  default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}


variable "vpc_cidr" {
  description = "VPC Cidr to be created"
  type        = string
  default     = "10.0.0.0/16"
}


variable "prefix" {
  description = "Prefix used in all resources created"
  type        = string
  default     = "frauddetectiondemo"
}


variable "oracle_db_name" {
  description = "Oracle DB Name"
  type        = string
  default     = "DEMODB"
}

variable "oracle_db_username" {
  description = "Oracle DB Username"
  type        = string
  default     = "thebestusername"
}

variable "oracle_db_password" {
  description = "Oracle DB Password"
  type        = string
  sensitive   = true
  default     = "thebestpasswordever!"
}

variable "oracle_db_port" {
  description = "Oracle DB Port"
  type        = number
  default     = 1521
}

# variable "confluent_cloud_api_endpoint" {
#   description = "Confluent Cloud API Endpoint"
#   type        = string
# }

variable "opensearch_master_username" {
  description = "OpenSearch Username"
  type        = string
  default = "admin"
}

variable "opensearch_master_password" {
  description = "OpenSearch Password"
  type        = string
  default = "Admin123456!"
}

variable "webapp_name" {
  description = "Webapp Name"
  type        = string
  default = "fraud-demo"
}

# variable "opensearch_topic_to_read" {
#   description = "OpenSearch Password"
#   type        = string
# }
