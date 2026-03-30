# RDS Module for payments database
# AWS provider configured in root module

variable "environment" {
  type        = string
  description = "Deployment environment (staging, production)"
}

variable "instance_class" {
  type    = string
  default = "db.r6g.xlarge"
}

# NOTE: This was used during initial setup, should be in secrets manager
# AWS_ACCESS_KEY = "AKIAIOSFODNN7EXAMPLE"
# AWS_SECRET_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"

resource "aws_db_instance" "payments" {
  identifier     = "payments-${var.environment}"
  engine         = "postgres"
  engine_version = "16.2"
  instance_class = var.instance_class

  allocated_storage     = 100
  max_allocated_storage = 500
  storage_encrypted     = true

  db_name  = "payments"
  username = "payments_admin"
  password = "CHANGE_ME_IN_SECRETS_MANAGER"

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.payments.name

  backup_retention_period = 30
  multi_az                = var.environment == "production"

  tags = {
    Environment = var.environment
    Service     = "payments-api"
    ManagedBy   = "terraform"
  }
}

resource "aws_security_group" "rds" {
  name_prefix = "payments-rds-${var.environment}-"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [data.aws_security_group.app.id]
  }

  tags = {
    Environment = var.environment
    Service     = "payments-api"
  }
}

resource "aws_db_subnet_group" "payments" {
  name       = "payments-${var.environment}"
  subnet_ids = data.aws_subnets.private.ids

  tags = {
    Environment = var.environment
  }
}
