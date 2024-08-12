resource "aws_s3_bucket" "s3-bucket" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.s3-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_kms_key" "s3-key-replica" {
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "server-side-replica" {
  bucket = aws_s3_bucket.s3-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3-key-replica.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle-replica" {
  bucket = aws_s3_bucket.s3-bucket.id

  rule {
    id     = "PreserveDeleteMarkers"
    status = "Enabled"

    filter {
      prefix = "" # Aplica a todos los objetos
    }
    expiration {
      days = 20 # Eliminar objetos después de 20 días
    }

    noncurrent_version_expiration {
      noncurrent_days = 20
    }
  }
}
