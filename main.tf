# NovaPay Infrastructure — Main Terraform Configuration

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "novapay-terraform-state"
    key            = "infrastructure/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "novapay"
      ManagedBy   = "terraform"
      Team        = "platform"
    }
  }
}

# VPC
module "vpc" {
  source = "./modules/vpc"

  environment     = var.environment
  vpc_cidr        = var.vpc_cidr
  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs
}

# ECS Cluster
module "ecs" {
  source = "./modules/ecs"

  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnet_ids

  services = {
    api_gateway    = { cpu = 512, memory = 1024, desired_count = 3 }
    users_service  = { cpu = 256, memory = 512,  desired_count = 2 }
    payments_core  = { cpu = 512, memory = 1024, desired_count = 3 }
    credit_service = { cpu = 256, memory = 512,  desired_count = 2 }
  }
}

# RDS PostgreSQL
module "rds" {
  source = "./modules/rds"

  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnet_ids
  instance_class    = var.db_instance_class
  multi_az          = var.environment == "production"
  backup_retention  = var.environment == "production" ? 30 : 7
}

# ElastiCache Redis
module "redis" {
  source = "./modules/redis"

  environment   = var.environment
  vpc_id        = module.vpc.vpc_id
  subnet_ids    = module.vpc.private_subnet_ids
  node_type     = var.redis_node_type
  num_cache_nodes = var.environment == "production" ? 3 : 1
}
