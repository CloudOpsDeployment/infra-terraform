locals {
  microservices = [
    "frontend",
    "cartservice",
    "productcatalogservice",
    "currencyservice",
    "paymentservice",
    "shippingservice",
    "emailservice",
    "checkoutservice",
    "recommendationservice",
    "adservice",
    "loadgenerator"
  ]
}

resource "aws_ecr_repository" "ecr" {
  for_each             = toset(local.microservices)
  name                 = "${var.project_name}-${each.key}-ecr-repo"
  image_tag_mutability = "MUTABLE"

  force_delete = true #utilizado porque es desarrollo

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    project     = "cloudops-ecommerce-app"
    environment = var.environment
    managed_by  = "terraform"
    owner       = "juan"
  }
}

# Regla de limpieza
resource "aws_ecr_lifecycle_policy" "keep_last_10" {
  for_each = aws_ecr_repository.ecr

  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Mantener solo las ultimas 10 imagenes para ahorrar costos"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}