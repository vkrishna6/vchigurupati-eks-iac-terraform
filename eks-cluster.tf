# Create EKS cluster using eks terraform module.
#reference - https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  #create/enable OIDC identity provider to allow IAM roles for service accounts for Load balancer controller to access ELB
  enable_irsa = true

  bootstrap_self_managed_addons = false
  #This block install add-ons into the cluster. It will install the latest support version. 
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  # Set to true. cluster API is publicly accessible using kubectl & permissions. 
  # If we set this to false then cluster access is restricted or only accessible via a bastion instance.
  # We can use "cluster_endpoint_public_access_cidrs" to restrict the access. 
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