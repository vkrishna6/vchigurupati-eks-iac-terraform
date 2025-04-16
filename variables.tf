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
