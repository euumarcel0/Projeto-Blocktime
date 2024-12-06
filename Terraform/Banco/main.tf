provider "aws" {
  region                  = "us-west-2"
  access_key              = "AKIA4MJ4TNCYLN2IDEEV"
  secret_key              = "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"
}

# Referenciar a VPC existente pelo ID
data "aws_vpc" "existing" {
  id = "vpc-0bb5a9dd1e69c79d0"  # ID da sua VPC existente
}

# Usar as subnets existentes em vez de criar novas
resource "aws_db_subnet_group" "my_rds_subnet_group" {
  name       = "bancosg"
  subnet_ids = [
    "subnet-0d33333e9ddb7e126",  # ID da primeira subnet
    "subnet-078d1e51810f806a4"   # ID da segunda subnet
  ]

  tags = {
    Name = "bancoSG"
  }
}

resource "aws_security_group" "rds_sg" {
  name_prefix = "rds_sg"
  description = "Security group for RDS instance"
  vpc_id      = data.aws_vpc.existing.id  # Referenciando a VPC correta

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
}

resource "aws_db_instance" "my_rds_instance" {
  identifier              = "banco"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.medium"  # Classe de instância mais econômica
  allocated_storage       = 50            # Armazenamento mínimo recomendado para MySQL
  username                = "admin"
  password                = "blocktime134" # Defina uma senha segura
  db_name                 = "billingdb"
  publicly_accessible     = true        # Evitar acessos externos desnecessários
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.my_rds_subnet_group.name

  tags = {
    Name        = "banco-instance"
    Environment = "production"
  }

  # Removendo final snapshot e desativando Multi-AZ para economizar
  skip_final_snapshot       = true          # Sem snapshots finais ao destruir
  backup_retention_period   = 0             # Sem backups automáticos
  multi_az                  = false         # Apenas uma zona para menor custo
  auto_minor_version_upgrade = false        # Evita atualizações automáticas que podem causar custos adicionais
}
