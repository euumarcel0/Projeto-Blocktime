provider "aws" {
  region = "us-east-1" # Altere para sua região desejada
}

# Criação do bucket S3 para os relatórios
resource "aws_s3_bucket" "relatorios3s" {
  bucket        = "relatorios3"
  force_destroy = true # Permite a exclusão do bucket mesmo se houver objetos dentro dele
}

# Políticas do bucket S3 para os relatórios
resource "aws_s3_bucket_policy" "relatorios3s_policy" {
  bucket = aws_s3_bucket.relatorios3s.id
  policy = jsonencode({
    Version = "2008-10-17"
    Id      = "PolicyForAthenaAndCUR"
    Statement = [
      {
        Sid    = "AllowBillingReports"
        Effect = "Allow"
        Principal = {
          Service = "billingreports.amazonaws.com"
        }
        Action = [
          "s3:GetBucketAcl",
          "s3:GetBucketPolicy"
        ]
        Resource = "arn:aws:s3:::relatorios3"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = "456190393883"
            "aws:SourceArn"     = "arn:aws:cur:us-east-1:456190393883:definition/*"
          }
        }
      },
      {
        Sid    = "AllowPutObjects"
        Effect = "Allow"
        Principal = {
          Service = "billingreports.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::relatorios3/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = "456190393883"
            "aws:SourceArn"     = "arn:aws:cur:us-east-1:456190393883:definition/*"
          }
        }
      },
      {
        Sid    = "AllowAthenaAccess"
        Effect = "Allow"
        Principal = {
          Service = "athena.amazonaws.com"
        }
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::relatorios3",
          "arn:aws:s3:::relatorios3/*"
        ]
      },
      {
        Sid    = "AWSCloudTrailAclCheck20150319-d53e44d5-db94-4855-9364-769706ee9680"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = "arn:aws:s3:::relatorios3"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudtrail:us-east-1:456190393883:trail/my-cloudtrail"
          }
        }
      },
      {
        Sid    = "AWSCloudTrailWrite20150319-44f9d4ed-bfac-4584-9a66-8b6cc0f71ce3"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::relatorios3/AWSLogs/456190393883/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "arn:aws:cloudtrail:us-east-1:456190393883:trail/my-cloudtrail"
            "s3:x-amz-acl"  = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

#Configurar Athena#


# Configuração do Cost and Usage Report
resource "aws_cur_report_definition" "cost_usage_report" {
  report_name                = "MonthlyCostAndUsageReport"
  time_unit                  = "DAILY" # Ou "HOURLY", dependendo da sua necessidade
  format                     = "textORcsv"
  compression                = "GZIP"
  s3_bucket                  = aws_s3_bucket.relatorios3s.id
  s3_prefix                  = "cur-reports/"
  report_versioning          = "CREATE_NEW_REPORT" # Ou "OVERWRITE_EXISTING_REPORT"
  s3_region                  = "us-east-1"         # Altere para a região do seu bucket
  additional_schema_elements = ["RESOURCES"]

  depends_on = [
    aws_s3_bucket.relatorios3s,
    aws_s3_bucket_policy.relatorios3s_policy
  ]
}

# Criando um tópico SNS para notificações
resource "aws_sns_topic" "cost_alerts" {
  name = "cost-alerts-topic"
}

# Política do tópico SNS para permitir que CloudTrail publique no tópico
resource "aws_sns_topic_policy" "cost_alerts_policy" {
  arn = aws_sns_topic.cost_alerts.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.cost_alerts.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = "arn:aws:cloudtrail:us-east-1:456190393883:trail/my-cloudtrail"
          }
        }
      }
    ]
  })
}

# Alarmes para uso de CPU EC2
resource "aws_cloudwatch_metric_alarm" "cpu_alarm_ec2" {
  alarm_name          = "CPU_Usage_Alarm_EC2"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80" # Alerta se uso de CPU > 80%
  alarm_actions       = [aws_sns_topic.cost_alerts.arn]

  dimensions = {
    InstanceId = "i-0a80937f62a14d2d3" # ID da sua instância EC2
  }
}

# Alarmes para uso de memória EC2
resource "aws_cloudwatch_metric_alarm" "memory_alarm_ec2" {
  alarm_name          = "Memory_Usage_Alarm_EC2"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "System/Linux"
  period              = "300"
  statistic           = "Average"
  threshold           = "80" # Alerta se uso de memória > 80%
  alarm_actions       = [aws_sns_topic.cost_alerts.arn]

  dimensions = {
    InstanceId = "i-0a80937f62a14d2d3" # ID da sua instância EC2
  }
}

# Alarmes para IOPS EC2
resource "aws_cloudwatch_metric_alarm" "iops_alarm_ec2" {
  alarm_name          = "IOPS_Alarm_EC2"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "DiskReadOps"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1000" # Alerta se IOPS > 1000
  alarm_actions       = [aws_sns_topic.cost_alerts.arn]

  dimensions = {
    InstanceId = "i-0a80937f62a14d2d3" # ID da sua instância EC2
  }
}

# Alarmes para uso de CPU RDS
resource "aws_cloudwatch_metric_alarm" "cpu_alarm_rds" {
  alarm_name          = "CPU_Usage_Alarm_RDS"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80" # Alerta se uso de CPU > 80%
  alarm_actions       = [aws_sns_topic.cost_alerts.arn]

  dimensions = {
    DBInstanceIdentifier = "database-1" # ID da sua instância RDS
  }
}

# Alarmes para uso de memória RDS
resource "aws_cloudwatch_metric_alarm" "memory_alarm_rds" {
  alarm_name          = "Memory_Usage_Alarm_RDS"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "1000000000" # Alerta se memória livre < 1 GB
  alarm_actions       = [aws_sns_topic.cost_alerts.arn]

  dimensions = {
    DBInstanceIdentifier = "database-1" # ID da sua instância RDS
  }
}

# Alarmes para IOPS RDS
resource "aws_cloudwatch_metric_alarm" "iops_alarm_rds" {
  alarm_name          = "IOPS_Alarm_RDS"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ReadIOPS"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1000" # Alerta se IOPS > 1000
  alarm_actions       = [aws_sns_topic.cost_alerts.arn]

  dimensions = {
    DBInstanceIdentifier = "database-1" # ID da sua instância RDS
  }
}


# Configuração do CloudTrail
resource "aws_cloudtrail" "main" {
  name                          = "my-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.relatorios3s.id
  is_multi_region_trail         = true
  enable_logging                = true
  include_global_service_events = true
  sns_topic_name                = aws_sns_topic.cost_alerts.name

  event_selector {
    read_write_type           = "All"
    include_management_events = true
    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::${aws_s3_bucket.relatorios3s.id}/"]
    }
  }
}

