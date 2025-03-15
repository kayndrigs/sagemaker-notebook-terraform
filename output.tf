# Output important information
output "sagemaker_domain_id" {
  value = aws_sagemaker_domain.test_domain.id
}

output "sagemaker_user_profile" {
  value = aws_sagemaker_user_profile.test_user.user_profile_name
}

output "s3_bucket_name" {
  value = aws_s3_bucket.sagemaker_bucket.bucket
}