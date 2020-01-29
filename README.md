## Description
This terraform code is used to setup AWS VPC with required parameters together with needed shared resources such as s3 buckets, WAF IP sets, rules, ACLs.
Based on Hashicorp's [VPC module](https://github.com/terraform-aws-modules/terraform-aws-vpc) 
and Lean Delivery's [AWS Core module](https://github.com/lean-delivery/tf-module-aws-core)

## How to use
**0. get clean terraform service, go to "0_terraform_infra" and init terraform**
```
terraform init
```

**1. create "nonprod" workspace**
```
terraform workspace new nonprod
```

**2. create "prod" workspace**
```
terraform workspace new prod
```

*to select appropriate workspace*
```
terraform workspace select nonprod
```

**3. go to "0_terraform_infra/tfvars" and create a file "{project name}-{workspace}.tfvars":**
```
nano nbcu-nonprod.tfvars
```
*content of the file below:*
```
project = "nbcu"
environment = "nonprod"
aws_region = "us-east-2"
```

**4. apply changes with defined vars file, run below command on the level "0_terraform_infra"**
```
terraform apply -var-file=tfvars/nbcu-nonprod.tfvars
```

*aws s3 bucket and a DynamoDB table should be created as a result*
_*.hcl file should be created on the same level with "0_terraform_infra" and "1_core"_

**5. go to "1_core" and init terraform also defined *.hcl file with backend configuration**
```
terraform init -backend-config=../nbcu-nonprod.hcl
```

**6. go to "1_core/tfvars" and create a file "{workspace name}-{aws region}.tfvars", example content is below**
```
nano nbcu-nonprod.tfvars
```
*example content*
```
project = "nbcu"

region = "us-east-2"

availability_zones = ["us-east-2a", "us-east-2b"]

vpc_cidr = "10.0.0.0/16"

private_subnets = ["10.0.0.0/24", "10.0.1.0/24"]

public_subnets = ["10.0.2.0/25", "10.0.2.128/25"]

enable_nat_gateway = "true"
```

**7. return to "1_core" and apply changes with defined vars file**
```
terraform apply -var-file=tfvars/nonprod-us-east-2.tfvars
```

**8. go to "2_shared_resources" and init terraform also defined *.hcl file with backend configuration**
```
terraform init -backend-config=../nbcu-nonprod.hcl
```

**9. go to "2_shared_resources/tfvars" and create a file "{workspace name}-{aws region}.tfvars", example content is below**
```
nano nbcu-nonprod.tfvars
```
*example content*
```
project = "nbcu"
environment = "nonprod"
aws_region = "us-east-2"
whitelist = ["213.184.243.0/24", "217.21.56.0/24", "217.21.63.0/24", "213.184.231.0/24", "86.57.255.0/24", "194.158.197.0/24", "82.209.214.0/24", "82.209.214.0/24", "86.57.167.0/24", "82.209.234.0/24", "86.57.244.0/24", "178.124.152.0/24", "174.128.55.228/32"]
aws_waf_rule_name = "GrantAccess"
aws_waf_rule_metric_name = "GrantAccessWAFRule"
aws_waf_web_acl_name = "WhiteListACL"
aws_waf_web_acl_metric_name = "WhiteListACL"
```

**10. return to "2_shared_resources" and apply changes with defined vars file**
```
terraform apply -var-file=tfvars/nonprod-us-east-2.tfvars
```

**11. to destroy infra run command:**
```
terraform destroy -var-file=tfvars/nonprod-us-east-2.tfvars
```