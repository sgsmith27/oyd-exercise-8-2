output "ci_runner_role_arn" {
  description = "ARN of the IAM role assumed by GitHub Actions through OIDC"
  value       = aws_iam_role.ci_runner.arn
}

output "secret_arn" {
  description = "ARN of the database password secret"
  value       = aws_secretsmanager_secret.db_password.arn
}