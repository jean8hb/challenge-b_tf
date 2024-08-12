locals {
  numero_buckets     = range(1, 5) # Cambiar aquí para crear entre 1 y 100 buckets
  replication_region = "us-east-2"
}

### Módulo para crear buckets en la región principal
module "s3_main" {
  source      = "./modules/s3"
  region      = local.region
  bucket_name = "s3-${local.region}-${local.environment}-${count.index + 1}"
  count       = length(local.numero_buckets)
  tags = {
    Name = "s3-${local.region}-${local.environment}-${count.index + 1}"
  }
  replication_enabled = true
  replication_role    = aws_iam_role.s3_replication_role.arn
  replication_bucket  = "s3-${local.replication_region}-${local.environment}-${count.index + 1}"
}

### Módulo para crear buckets en la región replica
module "s3_replica" {
  source      = "./modules/s3_replica"
  providers   = { aws = aws.replica_provider }
  region      = local.replication_region
  bucket_name = "s3-${local.replication_region}-${local.environment}-${count.index + 1}"
  count       = length(local.numero_buckets)
  tags = {
    Name = "s3-${local.replication_region}-${local.environment}-${count.index + 1}"
  }
}

output "s3_bucket_id" {
  value = module.s3_main[*].s3_bucket_id
}

output "s3_bucket_arn" {
  value = module.s3_main[*].s3_bucket_arn
}

# Definición del rol IAM para la replicación
resource "aws_iam_role" "s3_replication_role" {
  name = "s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "s3_replication_policy" {
  role = aws_iam_role.s3_replication_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket",
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectLegalHold",
          "s3:GetObjectVersionTagging",
          "s3:GetObjectRetention"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
