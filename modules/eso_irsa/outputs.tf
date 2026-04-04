output "eso_role_arn" {
  value       = aws_iam_role.eso_role.arn
  description = "Este es el ARN del rol, para utilizar por el eso desplegado"
}