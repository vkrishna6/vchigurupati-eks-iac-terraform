variable "region" {
  description = "AWS region"
  type        = string
#  default     = "us-east-1"
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
#  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of public subnet CIDRs"
#  default  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of private subnet CIDRs"
#  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "cluster_name" {
  type        = string
#  default     = "test-cluster1"
}

variable "cluster_version" {
  type        = string
  default     = "1.32"
#  description = "Kubernetes version for the EKS cluster"
}

variable "instance_types" {
  type        = list(string)
  default     = ["m5.xlarge"]
#  description = "Instance types for the EKS managed node group"
}
