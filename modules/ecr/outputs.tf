output "ecr_repository_urls" {
  description = "Mapa de nombres de microservicios a sus respectivas URLs de ECR"
  value = {
    for k, repo in aws_ecr_repository.ecr : k => repo.repository_url
  }
}