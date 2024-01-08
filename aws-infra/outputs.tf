output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_ca_cert" {
  value = module.eks.cluster_certificate_authority_data
}

output "s3-bucket" {
  value = aws_s3_bucket.s3-bucket.id
}

output "oidc-role" {
  value = aws_iam_role.oidc-role.arn
}