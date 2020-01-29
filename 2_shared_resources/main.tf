terraform {
  backend "s3" {
    key                  = "shared_resources.tfstate"
    workspace_key_prefix = "shared_resources"
  }
}

resource "random_string" "uid" {
  length  = 8
  lower   = true
  number  = true
  special = false
  upper   = false
}

locals {
  lambda_artifactory_s3_bucket = signum(length(var.lambda_artifactory_s3_bucket)) >= 1 ? var.lambda_artifactory_s3_bucket : "${var.project}-${var.environment}-lambda-artifactory-${random_string.uid.result}"
  swagger_files_s3_bucket = signum(length(var.swagger_files_s3_bucket)) >= 1 ? var.swagger_files_s3_bucket : "${var.project}-${var.environment}-swagger-files-${random_string.uid.result}"
  static_site_s3_bucket = signum(length(var.static_site_s3_bucket)) >= 1 ? var.static_site_s3_bucket : "${var.project}-${var.environment}-static-site-${random_string.uid.result}"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "lambda_artifactory" {
  bucket   = local.lambda_artifactory_s3_bucket
  acl      = "private"

  tags = {
    Description = "Lambda deploy S3 bucket"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "swagger_files" {
  bucket   = local.swagger_files_s3_bucket
  acl      = "private"

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
  
  tags = {
    Description = "Swagger files S3 bucket"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_s3_bucket" "static_site" {
  bucket   = local.static_site_s3_bucket
  acl      = "public-read"

  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  tags = {
    Description = "Static site S3 bucket for FE artifact deploy by serverless framework"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_s3_bucket_policy" "publicly_readable_objects" {
  depends_on  = [aws_s3_bucket.static_site]
  bucket = local.static_site_s3_bucket

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${local.static_site_s3_bucket}/*"
        }
    ]
}
POLICY
}


resource "aws_wafregional_ipset" "waf_api_ipset" {
  name = "IP_Set-${var.project}-${var.environment}"

  dynamic "ip_set_descriptor" {
    for_each = var.whitelist
    content {
      type  = "IPV4"
      value = ip_set_descriptor.value
    }
  }
}

resource "aws_wafregional_rule" "waf_api_rule" {
  depends_on  = [aws_wafregional_ipset.waf_api_ipset]
  name        = var.aws_wafregional_rule_name
  metric_name = var.aws_wafregional_rule_metric_name

  predicate {
    data_id = aws_wafregional_ipset.waf_api_ipset.id
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_wafregional_web_acl" "waf_api_acl" {
  depends_on  = [aws_wafregional_ipset.waf_api_ipset, aws_wafregional_rule.waf_api_rule]
  name        = var.aws_wafregional_web_acl_name
  metric_name = var.aws_wafregional_web_acl_metric_name

  default_action {
    type = "BLOCK"
  }

  rule {
    action {
      type = "ALLOW"
    }

    priority = 1
    rule_id  = aws_wafregional_rule.waf_api_rule.id
    type     = "REGULAR"
  }
}

resource "aws_iam_role" "lambda_deploy_iam_role" {
  name = "serverless-lambda-deploy"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_iam_policy" {
  name        = "lambda_iam"
  path        = "/"
  description = "Lambda IAM policy to be used by serverless framework for deployment"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "logs:CreateLogStream",
                "logs:CreateLogGroup"
            ],
            "Resource": [
                "arn:aws:logs:us-east-2:*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:us-east-2:*"
            ],
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_iam_attach" {
  role       = aws_iam_role.lambda_deploy_iam_role.name
  policy_arn = aws_iam_policy.lambda_iam_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_iam_attach_service_role" {
  role       = aws_iam_role.lambda_deploy_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}