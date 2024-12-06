# Provedor AWS
provider "aws" {
  region = "us-east-1"
}

# Criar o grupo de segurança para a instância EC2
resource "aws_security_group" "ec2_sg" {
  name_prefix = "ec2-sg-"
  description = "Security group for EC2 instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Permite acesso SSH de qualquer IP (ajuste conforme necessário)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Criar a instância EC2 sem IAM Role
resource "aws_instance" "ec2_instance" {
  ami           = "ami-03e383d33727f4804"  # Substitua com o ID da AMI do Amazon Linux 2 para sua região
  instance_type = "t2.micro"  # Ajuste o tipo de instância conforme necessário
  key_name      = "vockey"  # Substitua pelo nome do seu par de chaves

  # Correção: Substitua "security_group_ids" por "vpc_security_group_ids"
  vpc_security_group_ids  = [aws_security_group.ec2_sg.id]
  subnet_id               = "subnet-0fd8dd96c164113ee"  # Substitua com o ID da sua sub-rede

  tags = {
    Name = "EC2-Processing-Instance"
  }
}

# Criação de um Bucket S3 para armazenar os relatórios CUR (caso necessário)
resource "aws_s3_bucket" "cur_reports" {
  bucket = "relatorios3s"  # Nome do bucket onde os relatórios CUR são armazenados

  tags = {
    Name = "Bucket de Relatórios CUR"
  }
}


