# Descargar la política oficial de AWS para el LBC
data "http" "lbc_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.0/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "lbc" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = data.http.lbc_iam_policy.response_body
}

# IRSA: IAM Role asumible por el ServiceAccount del LBC
data "aws_iam_policy_document" "lbc_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:sub"
      # kube-system es el namespace del LBC
      # aws-load-balancer-controller es el nombre del ServiceAccount
      values = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "lbc" {
  name               = "online-boutique-lbc-role"
  assume_role_policy = data.aws_iam_policy_document.lbc_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lbc" {
  role       = aws_iam_role.lbc.name
  policy_arn = aws_iam_policy.lbc.arn
}

# Permisos complementarios mínimos para evitar AccessDenied en Gateway API
# (el controller necesita Describe/Modify listener attributes durante reconciliación)
resource "aws_iam_policy" "lbc_listener_attributes" {
  name = "AWSLoadBalancerControllerAdditionalListenerAttributesPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:DescribeListenerAttributes",
          "elasticloadbalancing:ModifyListenerAttributes"
        ]
        # El requisito de la API no permite especificar listener concretos con suficiente precisión aquí,
        # por lo que se usa wildcard. Esto es mínimo para la acción y no expande a servicios no relacionados.
        Resource = "arn:aws:elasticloadbalancing:*:*:listener/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lbc_listener_attributes" {
  role       = aws_iam_role.lbc.name
  policy_arn = aws_iam_policy.lbc_listener_attributes.arn
}
