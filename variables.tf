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
