data "aws_iam_policy_document" "cluster" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["eks.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "cluster" {
  name = "${var.project_id}-eks-cluster"
  assume_role_policy = data.aws_iam_policy_document.cluster.json
}

resource "aws_iam_role_policy_attachment" "cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "VPC" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}

resource "aws_security_group" "cluster" {
  name = "${var.project_id}-eks-cluster"
  vpc_id = var.vpc_id

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks   = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_id}-eks"
  }
}

resource "aws_eks_cluster" "default" {
  name      = var.project_id
  role_arn  = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids              = var.cluster_subnet_ids
    security_group_ids      = [aws_security_group.cluster.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster,
    aws_iam_role_policy_attachment.VPC
  ]

  tags = {
    Name = "${var.project_id}-default"
  }
}
