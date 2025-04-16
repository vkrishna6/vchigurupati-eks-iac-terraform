variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
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
  default     = "vpc-0447c1683dab54521"
}

variable "subnet_ids" {
  type        = list
  default     = ["subnet-01cd7e89e203f4dce","subnet-0c1648c3eec6f733e","subnet-0d8334e53ad06e06b"]
}

variable "instance_types" {
  type        = list
  default     = ["m5.xlarge"]
}