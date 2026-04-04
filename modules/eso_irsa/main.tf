# data sources para armar dinámicamente el ARN de SSM con la cuenta
data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "eso_ssm_policy" {
  name        = "ExternalSecretsOperatorSSMPolicy"
  description = "Permisos para que ESO lea parametros bajo /cloudops-deployment-app/*"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        # Se restringe estrictamente el acceso al path requerido
        Resource = [
          "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:/cloudops-ecommerce-app/*",
          "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:cloudops-ecommerce-app/*"
        ]
      }
    ]
  })
}

# Trust Policy (IRSA): Asumir el rol a través del OIDC de EKS
data "aws_iam_policy_document" "eso_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:external-secrets:external-secrets"]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

# IAM Role: Creación del rol con la política de confianza
resource "aws_iam_role" "eso_role" {
  name               = "eso-irsa-role"
  assume_role_policy = data.aws_iam_policy_document.eso_assume_role_policy.json
}

#  Attachment: Vincular la política de SSM al Role
resource "aws_iam_role_policy_attachment" "eso_role_policy_attach" {
  role       = aws_iam_role.eso_role.name
  policy_arn = aws_iam_policy.eso_ssm_policy.arn
}
