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
  
  tags = {
    Name = "test-vpc"
    vpcname= "test-vpc"
  }
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
  }
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