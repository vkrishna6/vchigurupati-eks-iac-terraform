variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc" {
  description = "AWS VPC name"
  type        = string
  default     = "test-vpc1"
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of public subnet CIDRs"
  default  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of private subnet CIDRs"
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "cluster_name" {
  type        = string
  default     = "test-cluster1"
}

variable "cluster_version" {
  type        = number
  default     = 1.32
}

variable "vpc_id" {
  type        = string
  default     = "vpc-ID"
}

variable "subnet_ids" {
  type        = list
  default     = ["subnet-ID","subnet-ID2","subnet-ID3"]
}

variable "instance_types" {
  type        = list
  default     = ["m5.xlarge"]
}
