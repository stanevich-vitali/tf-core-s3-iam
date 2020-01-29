output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.core.vpc_id
}

output "environment" {
  value = local.environment
}

output "project" {
  value = module.core.project
}

output "region" {
  value = var.region
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.core.database_subnets
}

output "database_subnets_cidr_blocks" {
  description = "List of cidr_blocks of database subnets"
  value       = module.core.database_subnets_cidr_blocks
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.core.private_subnets
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = module.core.private_subnets_cidr_blocks
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.core.public_subnets
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = module.core.public_subnets_cidr_blocks
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = module.core.default_security_group_id
}

output "virtual_private_gateway" {
  description = "The ID of the NAT gateway" //if exists

  value = module.core.vgw_id
}

