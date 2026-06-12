variable "project" {
  description = "Project name used for resource naming"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository allowed to assume the CI role"
  type        = string
}