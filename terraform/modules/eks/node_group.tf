data "aws_iam_policy_document" "node_group" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "node_group" {
  name = "${var.project_id}-eks-node-group"
  assume_role_policy = data.aws_iam_policy_document.node_group.json
}
resource "aws_iam_role_policy_attachment" "CNI" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "ECR" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "worker_node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group.name
}

resource "aws_eks_node_group" "default" {
  node_group_name   = "${var.project_id}-default"
  cluster_name      = aws_eks_cluster.default.name
  node_role_arn     = aws_iam_role.node_group.arn
  subnet_ids        = var.node_group_subnet_ids

  instance_types    = [ var.node_instance_type ]

  scaling_config {
    desired_size  = 2
    max_size      = 4
    min_size      = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.ECR,
    aws_iam_role_policy_attachment.CNI,
    aws_iam_role_policy_attachment.worker_node
  ]

  tags = {
    Name = "${var.project_id}-default"
  }
}
