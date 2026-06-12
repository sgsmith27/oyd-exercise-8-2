terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.6"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

resource "aws_iam_role" "ci_runner" {
  name = "${var.project}-ci-runner"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:ref:refs/heads/main"
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ci_runner" {
  name = "${var.project}-ci-runner-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:GetCallerIdentity",
          "iam:GetRole",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListAttachedRolePolicies",
          "iam:ListRolePolicies",
          "iam:GetOpenIDConnectProvider",
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ci_runner" {
  role       = aws_iam_role.ci_runner.name
  policy_arn = aws_iam_policy.ci_runner.arn
}

resource "aws_secretsmanager_secret" "db_password" {
  name = "${var.project}-db-password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = "changeme-in-rotation"

  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }
}