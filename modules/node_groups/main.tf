data "aws_iam_policy_document" "node_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"] # los nodos son EC2, no EKS
    }
  }
}

resource "aws_iam_role" "eks_nodes" {
  name               = "${var.cluster_name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role.json
}

locals {
  node_policies = {
    # Permite al kubelet registrarse en el cluster y reportar estado
    worker = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    # Permite al VPC CNI crear y gestionar ENIs para asignar IPs a pods
    vpc_cni = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    # Permite al kubelet hacer pull de imágenes desde ECR
    ecr = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }
}

resource "aws_iam_role_policy_attachment" "node_policies" {
  for_each   = local.node_policies
  role       = aws_iam_role.eks_nodes.name
  policy_arn = each.value
}

resource "aws_eks_node_group" "this" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  instance_types = [var.node_instance_type]
  capacity_type  = "ON_DEMAND"

  ami_type  = "AL2023_x86_64_STANDARD" # Amazon Linux 2023 Standard — EKS selects latest recommended AMI automatically
  disk_size = 20                       # Tamaño del disco raíz en GB (default 20GB)
  tags = merge(
    {
      "k8s.io/cluster-autoscaler/enabled"             = "true"
      "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      "kubernetes.io/cluster/${var.cluster_name}"     = "owned"
    },
    var.node_group_tags
  )
  update_config {
    max_unavailable = 1 # Número máximo de nodos que pueden estar indisponibles durante una actualización
  }

  labels = {
    role = "general"
  }
}
