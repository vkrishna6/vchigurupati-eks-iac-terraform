# Reference - https://github.com/terraform-aws-modules/terraform-aws-eks

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

# Create a VPC with "10.0.0.0/16" CIDR block.
resource "aws_vpc" "test-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "test-vpc"
    vpcname= "test-vpc"
  }
}

#output VPC ID 
output "vpc_id" {
  value = aws_vpc.test-vpc.id
}

# Create a public subnet with the CIDR range and availability_zones defined in variables.tf file. 
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.test-vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
    "kubernetes.io/role/elb"        = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"

  }
}

# Create a Private subnet with the CIDR range and availability_zones defined in variables.tf file. 
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.test-vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "private-subnet-${count.index + 1}"
    "kubernetes.io/role/internal-elb"     = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

#output Public and Private subnet IDs
output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}



# Create a IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.test-vpc.id

  tags = {
    Name = "test-vpc-igw"
  }
}

# Create a route table for public subnets - routetable1
resource "aws_route_table" "routetable1" {
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "routetable1-route-table"
    subnets_included = "public"
  }
}

# Route Table - routetable1 association with Public Subnets
resource "aws_route_table_association" "routetable1" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.routetable1.id
}

# Create elastic IP 
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

#Create a NAT gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id  # it will Use first public subnet.

  tags = {
    Name = "test-vpc-nat-gateway"
  }
}

#Create a private route table and mention the nat gateway id.
resource "aws_route_table" "routetable2" {
  vpc_id = aws_vpc.test-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "routetable2-route-table"
    subnets_included = "private"
  }
}

#associate private subnets to routing table created with NAT gateway route.
resource "aws_route_table_association" "routetable2" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.routetable2.id
}



#---------------EKS Cluster creation section------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.35.0"
}




# Create EKS cluster using eks terraform module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  enable_irsa = true

  bootstrap_self_managed_addons = false
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  # Optional
  cluster_endpoint_public_access = true

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = aws_vpc.test-vpc.id
  subnet_ids               = aws_subnet.private[*].id

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = var.instance_types
  }

  cluster_role_arn = aws_iam_role.eks_cluster_role.arn

  eks_managed_node_groups = {
    workernodegroup1 = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS-managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = var.instance_types

      min_size     = 2
      max_size     = 4
      desired_size = 3
      iam_role_arn = aws_iam_role.eks_node_group_role.arn
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}