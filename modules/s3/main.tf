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

resource "aws_s3_bucket_public_access_block" "s3-bucket-acl" {
  bucket                  = aws_s3_bucket.s3-bucket.id
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  restrict_public_buckets = var.restrict_public_buckets
  ignore_public_acls      = true
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.s3-bucket.id

  rule {
    id     = "PreserveDeleteMarkers"
    status = "Enabled"

    filter {
      prefix = "" # Aplica a todos los objetos
    }
    expiration {
      days = 30 # Eliminar objetos después de 30 días
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

resource "aws_kms_key" "s3-key" {
  deletion_window_in_days = 7
}

resource "aws_s3_bucket_server_side_encryption_configuration" "server-side" {
  bucket = aws_s3_bucket.s3-bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3-key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_replication_configuration" "replica" {
  bucket = aws_s3_bucket.s3-bucket.id

  depends_on = [
    aws_s3_bucket_versioning.versioning
  ]

  role = var.replication_role

  rule {
    id     = "replication_rule"
    status = "Enabled"

    filter {
      prefix = "" # Aplica a todos los objetos
    }

    destination {
      bucket        = "arn:aws:s3:::${var.replication_bucket}"
      storage_class = "STANDARD"
    }

    # Añadir DeleteMarkerReplication
    delete_marker_replication {
      status = "Enabled"
    }
  }
}
