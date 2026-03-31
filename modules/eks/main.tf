# IAM Role para el control plane
data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster" {
  name               = "${var.cluster_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
}

# AmazonEKSClusterPolicy: permisos para el control plane
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Configuracion del cluster

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# OIDC provider para permitir que los nodos asuman su rol sin usar credenciales estáticas.

# Necesitamos el thumbprint TLS del OIDC endpoint para que IAM
# pueda verificar los tokens. aws_eks_cluster ya lo expone.
data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  # La URL del issuer OIDC es única por cluster — EKS la genera al crear el cluster
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer

  # sts.amazonaws.com es quien va a validar los tokens — STS es el "audience"
  client_id_list = ["sts.amazonaws.com"]

  # El thumbprint TLS permite a IAM verificar que el token viene
  # realmente de tu cluster y no de un impostor
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
}