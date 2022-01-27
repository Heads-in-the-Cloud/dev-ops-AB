output "endpoint" {
  value = aws_eks_cluster.default.endpoint
}
output "kubeconfig_certificate_authority_data" {
  value = aws_eks_cluster.default.certificate_authority[0].data
  sensitive = true
}
