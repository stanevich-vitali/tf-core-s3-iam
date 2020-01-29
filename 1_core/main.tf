terraform {
  backend "s3" {
    key                  = "core.tfstate"
    workspace_key_prefix = "core"
  }
}

provider "aws" {
  region = var.region
}

locals {
  environment = terraform.workspace == "default" ? "common" : replace(terraform.workspace, "-${var.region}", "")
}

module "core" {
  source = "github.com/lean-delivery/tf-module-aws-core.git?ref=1.0.0"

  project            = var.project
  environment        = local.environment
  availability_zones = var.availability_zones
  vpc_cidr           = var.vpc_cidr
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets

  database_subnets             = var.database_subnets
  create_database_subnet_group = false

  public_dedicated_network_acl   = false //true
  private_dedicated_network_acl  = false //true
  database_dedicated_network_acl = false //true

  # public_inbound_acl_rules  = [
  #   {
  #     rule_number = 1
  #     rule_action = "allow"
  #     from_port   = 22
  #     to_port     = 22
  #     protocol    = "6"
  #     cidr_block  = "0.0.0.0/0"
  #   },
  #   {
  #     rule_number = 2
  #     rule_action = "allow"
  #     from_port   = 80
  #     to_port     = 80
  #     protocol    = "6"
  #     cidr_block  = "0.0.0.0/0"
  #   },
  #   {
  #     rule_number = 3
  #     rule_action = "allow"
  #     from_port   = 443
  #     to_port     = 443
  #     protocol    = "6"
  #     cidr_block  = "0.0.0.0/0"
  #   },
  # ]
  # public_outbound_acl_rules = [
  #   {
  #     rule_number = 1
  #     rule_action = "allow"
  #     from_port   = 22
  #     to_port     = 22
  #     protocol    = "6"
  #     cidr_block  = "0.0.0.0/0"
  #   },
  #   {
  #     rule_number = 2
  #     rule_action = "allow"
  #     from_port   = 80
  #     to_port     = 80
  #     protocol    = "6"
  #     cidr_block  = "0.0.0.0/0"
  #   },
  #   {
  #     rule_number = 3
  #     rule_action = "allow"
  #     from_port   = 443
  #     to_port     = 443
  #     protocol    = "6"
  #     cidr_block  = "0.0.0.0/0"
  #   },
  # ]

  # private_inbound_acl_rules  = [
  #   {
  #     rule_number = 1
  #     rule_action = "allow"
  #     from_port   = 0
  #     to_port     = 0
  #     protocol    = "-1"
  #     cidr_block  = "0.0.0.0/0"
  #   },
  # ]
  # private_outbound_acl_rules = [
  #   {
  #     rule_number = 1
  #     rule_action = "allow"
  #     from_port   = 0
  #     to_port     = 0
  #     protocol    = "-1"
  #     cidr_block  = "0.0.0.0/0"
  #   },
  # ]

  # database_inbound_acl_rules  = [
  #   {
  #     rule_number = 1
  #     rule_action = "allow"
  #     from_port   = 3306
  #     to_port     = 3306
  #     protocol    = "6"
  #     cidr_block  = "0.0.0.0/0"
  #   },
  # ]
  # database_outbound_acl_rules = [
  #   {
  #     rule_number = 1
  #     rule_action = "allow"
  #     from_port   = 3306
  #     to_port     = 3306
  #     protocol    = "6"
  #     cidr_block  = "0.0.0.0/0"
  #   },
  # ]

  enable_nat_gateway = var.enable_nat_gateway //true
  enable_vpn_gateway = var.enable_vpn_gateway
}
