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


# S3 bucket for remote state
resource "aws_s3_bucket" "tf_state" {
  bucket = "dev-cluster-1-state"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Dev"
  }
}


# DynamoDB table for state locking
resource "aws_dynamodb_table" "tf_lock" {
  name         = "dev-cluster-table1"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform Lock Table"
    Environment = "Dev"
  }
}

#create IAM policy for S3 bucket and dynamodb table
resource "aws_iam_policy" "terraform_state_access" {
  name        = "TerraformStateAccessPolicy"
  description = "Access policy for S3 and DynamoDB used by Terraform"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::dev-cluster-1-state",
          "arn:aws:s3:::dev-cluster-1-state/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:UpdateItem"
        ],
        Resource = "arn:aws:dynamodb:us-east-1:*:table/dev-cluster-table1"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_policy" {
  user       = aws_iam_user.eks-admin0414.name
  policy_arn = aws_iam_policy.terraform_state_access.arn
}
