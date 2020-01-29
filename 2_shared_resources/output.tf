output "s3_lambda_artifactory_bucket_name" {
  value = aws_s3_bucket.lambda_artifactory.id
}

output "s3_lambda_artifactory_bucket_arn" {
  value = aws_s3_bucket.lambda_artifactory.arn
}

output "s3_swagger_files_bucket_name" {
  value = aws_s3_bucket.swagger_files.id
}

output "s3_swagger_files_bucket_arn" {
  value = aws_s3_bucket.swagger_files.arn
}

output "s3_static_site_bucket_name" {
  value = aws_s3_bucket.static_site.id
}

output "s3_static_site_bucket_arn" {
  value = aws_s3_bucket.static_site.arn
}

