provider "aws" {
  region = var.aws_region
}

data "aws_eks_cluster" "selected_eks" {
  name = var.eks_cluster_name  # Nome do cluster EKS
}

data "aws_vpc" "eks_vpc" {
  id = data.aws_eks_cluster.selected_eks.vpc_config[0].vpc_id
}

data "aws_subnets" "eks_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.eks_vpc.id]
  }
}

data "aws_availability_zones" "available" {}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "lanchonete-rds-subnet-group"
  subnet_ids = data.aws_subnets.eks_subnets.ids

  tags = {
    Name = "rds-subnet-group"
  }
}

resource "aws_security_group" "rds_sg" {
  vpc_id = data.aws_vpc.eks_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Ajuste conforme necessário
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-security-group"
  }
}

resource "aws_db_instance" "rds_instance" {
  identifier              = "lanchonete-rds-instance"
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.medium"
  username                = var.rds_username
  password                = var.rds_password
  db_name                 = "lanchonete" # Nome do schema
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false # Melhor prática para segurança

  tags = {
    Name = "lanchonete-rds-instance"
  }
}
