variable "vpc_id" {
  description = "ID of the VPC where EKS will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS worker nodes"
  type        = list(string)
}

variable "cluster_name" {
  type        = string
#  default     = "test-cluster1"
}

variable "cluster_version" {
  type        = string
#  default     = "1.32"
  description = "Kubernetes version for the EKS cluster"
}

variable "instance_types" {
  type        = list(string)
#  default     = ["m5.xlarge"]
  description = "Instance types for the EKS managed node group"
}
