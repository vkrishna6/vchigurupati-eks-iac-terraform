# eks-iac-terraform

# 🚀 Terraform AWS EKS Cluster Deployment in a new VPC

I created this repository as a hands-on practice project to showcase my skills in Infrastructure as Code (IaC), Terraform, and AWS EKS deployment.  

This project uses the [terraform-aws-modules/eks](https://github.com/terraform-aws-modules/terraform-aws-eks) module to deploy a fully managed [Amazon EKS](https://aws.amazon.com/eks/) cluster with EKS-managed node groups.

---

## 📁 Project Structure

```bash
.
├── eks-cluster.tf         # EKS module setup with add-ons and node groups
├── iamroles.tf            # IAM roles for EKS cluster and worker nodes
├── main.tf                # VPC, subnets, routing tables, and NAT gateway
├── variables.tf           # Input variables


⚙️ Prerequisites
Terraform CLI ≥ 1.3
AWS account and credentials configured (~/.aws/credentials or env vars). IAM user running the terraform need permissions to create VPC, EKS cluster, and other resources in the AWS account. 
A pre-existing VPC and Subnets (public or private)

📌 The following resources will be provisioned during cluster creation
Custom VPC with public and private subnets
Internet Gateway and NAT Gateway
EKS Cluster provisioning
Managed Node Group with configurable instance type and scaling
Core EKS Add-ons: coredns, vpc-cni, kube-proxy, and eks-pod-identity-agent. 
IAM access for cluster creator
Tags for resource organization


## Commands to deploy, destroy, and access the cluster.
terrraform init - Initialize Terraform
terraform plan -out planfile - Review the execution plan
terraform apply planfile - Apply Terraform configuration
terraform 
terraform destroy - Destroy the resources
aws eks --region us-east-1 update-kubeconfig --name test-cluster1 - Update kubeconfig file for EKS cluster access

```
---
Author  
Vamsikrishna Chigurupati
