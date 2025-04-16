# eks-iac-terraform

# 🚀 Terraform AWS EKS Cluster Deployment

This project uses the [terraform-aws-modules/eks](https://github.com/terraform-aws-modules/terraform-aws-eks) module to deploy a fully managed [Amazon EKS](https://aws.amazon.com/eks/) cluster with EKS-managed node groups.

---

## 📁 Project Structure

```bash
.
├── main.tf          # Main Terraform configuration
├── variables.tf     # Input variables
└── README.md        # Project documentation


⚙️ Prerequisites
Terraform CLI ≥ 1.3
AWS account and credentials configured (~/.aws/credentials or env vars)
A pre-existing VPC and Subnets (public or private)

📌 Features
EKS Cluster provisioning
Managed Node Group with configurable instance type and scaling
Core EKS Add-ons: coredns, vpc-cni, kube-proxy, and eks-pod-identity-agent
IAM access for cluster creator
Custom VPC and Subnet support
Tags for resource organization


## Commands to deploy and destroy
terrraform init
terraform plan
terraform apply
terraform destroy
