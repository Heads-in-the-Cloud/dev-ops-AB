resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.project_id}/cluster"
  retention_in_days = 30

  tags = {
    Name = "${var.project_id}-eks"
    Environment = var.environment
  }
}
