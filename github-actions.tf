# Configurar GitHub como un Proveedor de Identidad OIDC en AWS
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  # Thumbprint oficial y estático de GitHub Actions
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# Definir la política de confianza (quién y bajo qué condiciones puede asumir el rol)
data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    # Condición 1: Asegurar que la audiencia (aud) es correcta
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Condición 2: Restricción estricta por repositorio y rama
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:CloudOpsDeployment/*:ref:refs/heads/main"]
    }
  }
}

# Crear el Rol IAM para GitHub Actions
resource "aws_iam_role" "github_actions" {
  name               = "github-actions-ecr-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

# Adjuntar la política gestionada de AWS (PowerUser de ECR) al rol
resource "aws_iam_role_policy_attachment" "github_actions_ecr_poweruser" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# Output del ARN del rol
output "github_actions_role_arn" {
  description = "ARN del rol de IAM asumible por GitHub Actions. Cópialo y pégalo como Secret en GitHub."
  value       = aws_iam_role.github_actions.arn
}