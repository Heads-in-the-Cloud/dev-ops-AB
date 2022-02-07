locals {
  tags = { "kubernetes.io/cluster/${var.project_id}" = "owned" }
}

resource "aws_iam_role" "fargate" {
  count = var.use_fargate ? 1 : 0

  name        = format("%s-fargate-profile", var.project_id)

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks-fargate-pods.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "fargate" {
  count = var.use_fargate ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate[0].name
}

resource "aws_eks_fargate_profile" "default" {
  count = var.use_fargate ? 1 : 0

  cluster_name           = var.project_id
  fargate_profile_name   = "default"
  pod_execution_role_arn = aws_iam_role.fargate[0].arn
  subnet_ids             = var.subnet_ids
  tags                   = local.tags

  selector {
    namespace = "fargate-profile"
  }
}
