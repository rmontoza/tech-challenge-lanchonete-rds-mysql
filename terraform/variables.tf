variable "rds_username" {
  description = "Username for the RDS instance"
  type        = string
  sensitive   = true
}

variable "rds_password" {
  description = "Password for the RDS instance"
  type        = string
  sensitive   = true
}
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
variable "eks_cluster_name" {
  description = "Nome do cluster EKS existente"
  type        = string
  default     = "lanchonete-eks-cluster"
}