variable "lambda_artifactory_s3_bucket" {
  description = "Name of S3 bucket to store deploy files for lambda"
  default     = ""
}

variable "swagger_files_s3_bucket" {
  description = "Name of S3 bucket to store swagger files, one bucket for all envs"
  default     = ""
}

variable "static_site_s3_bucket" {
  description = "Name of S3 bucket to store FE artifact deploy as a static site"
  default     = ""
}

variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-2"
}

variable "project" {
  description = "Project name"
  default     = "project"
}

variable "environment" {
  description = "environment name"
  default     = "environment"
}

variable "wafregional_ipset_name" {
  description = "WAF IP set name"
  default     = "WhiteList"
}

variable "whitelist" {
  description = "WAF ACL IP set range for whitelisting"
  type = list(string)
  default     = []
}

variable "aws_wafregional_rule_name" {
  description = "AWS WAF rule name"
  default     = "GrantAccess"
}

variable "aws_wafregional_rule_metric_name" {
  description = "AWS WAF rule metric name"
  default     = "tfWAFRule"
}

variable "aws_wafregional_web_acl_name" {
  description = "AWS WAF ACL name"
  default     = "WhiteListACL"
}

variable "aws_wafregional_web_acl_metric_name" {
  description = "AWS WAF ACL metric name"
  default     = "WhiteListACL"
}

variable "api_service_name" {
  description = "The name of the service deployed by serverless and also defined in serverless.yml"
  default     = "serverless-lyambda-deploy"
}

variable "api_stage" {
  description = "The definition of the API Gateway stage and also defined in serverless.yml as 'stage' parameter in 'provider' section"
  default     = "dev"
}
