# EKS Cluster Update to 1.28
# This module manages the EKS cluster for the payments platform

variable "cluster_version" {
  type    = string
  default = "1.28"
}

variable "environment" {
  type = string
}

resource "aws_eks_cluster" "main" {
  name     = "payments-${var.environment}"
  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = data.aws_subnets.private.ids
    endpoint_private_access = true
    endpoint_public_access  = var.environment != "production"
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_eks_node_group" "workers" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "workers-${var.environment}"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = data.aws_subnets.private.ids

  scaling_config {
    desired_size = var.environment == "production" ? 6 : 2
    max_size     = var.environment == "production" ? 12 : 4
    min_size     = var.environment == "production" ? 3 : 1
  }

  instance_types = ["m6i.xlarge"]

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
