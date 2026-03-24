# CLAUDE.md — infra-terraform

## Context
NovaPay infrastructure as code. All AWS resources managed via Terraform.
Never create resources via AWS Console.

## Rules
- All resources must have Environment, Project, ManagedBy, and Team tags
- Use modules for reusable infrastructure patterns
- State stored in S3 with DynamoDB locking — never local state
- Secrets in AWS Secrets Manager, never in tfvars or env vars
- Enable encryption at rest for all data stores (RDS, ElastiCache, S3)
- Multi-AZ required for production, optional for dev/staging
- All security groups follow least-privilege (no 0.0.0.0/0 ingress except ALB)
