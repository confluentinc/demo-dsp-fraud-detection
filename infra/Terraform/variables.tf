############### Global Variables
variable "region" {
  description = "The region of Confluent Cloud Network; If this is changed `availability_zones` variable must also be changed"
  type        = string
  default     = "us-west-2"
}

variable "prefix" {
  description = "Prefix used in all resources created"
  type        = string
  default     = "frauddetectiondemo"
}

################ Confluent Cloud Variables
variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)."
  type        = string
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret."
  type        = string
  sensitive   = true
}

############### AWS Variables
variable "aws_key" {
  description = "AWS API Key (with Lmabda Invoke Permission)."
  type        = string
}

variable "aws_secret" {
  description = "AWS API Secret."
  type        = string
  sensitive   = true
}

############### AWS Networking Variables
variable "availability_zones" {
  description = "List of availability zones to use for the private subnets"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "vpc_cidr" {
  description = "VPC Cidr to be created"
  type        = string
  default     = "10.0.0.0/16"
}

########## Oracle DB Variables
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

############# OpenSearch Variables
variable "opensearch_master_username" {
  description = "OpenSearch Username"
  type        = string
  default     = "admin"
}

variable "opensearch_master_password" {
  description = "OpenSearch Password"
  type        = string
  default     = "Admin123456!"
}

############# Kubernetes Variables
variable "webapp_name" {
  description = "Webapp Name"
  type        = string
  default     = "fraud-demo"
}

variable "webapp_namespace" {
  description = "Kubernetes Namespace to deploy application inside"
  type        = string
  default     = "frauddemo"
}

variable "windows_jump_server_password" {
  description = "Windows Jump server Admin Password"
  type        = string
  default     = "thatsAGoodPass"
}
