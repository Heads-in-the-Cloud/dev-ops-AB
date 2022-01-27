resource "aws_iam_role" "fargate_profile" {
  name = "${var.project_id}-eks-fargate"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate_profile.name
}
resource "aws_eks_fargate_profile" "default" {
  cluster_name           = aws_eks_cluster.default.name
  fargate_profile_name   = var.project_id
  pod_execution_role_arn = aws_iam_role.fargate_profile.arn
  subnet_ids             = var.subnet_ids

  selector {
    namespace = var.environment
  }
}
