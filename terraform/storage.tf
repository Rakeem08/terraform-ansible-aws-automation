# Assignment requirement: an S3 bucket.
# Enhancement: the bucket is encrypted, versioned, private, and used for Nginx log archives.
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "logs" {
  bucket        = "${local.name_prefix}-nginx-logs-${random_id.bucket_suffix.hex}"
  force_destroy = var.force_destroy_bucket

  tags = {
    Name    = "${local.name_prefix}-nginx-logs"
    Purpose = "Nginx log archive"
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  depends_on = [aws_s3_bucket_versioning.logs]

  rule {
    id     = "expire-old-nginx-logs"
    status = "Enabled"

    filter {
      prefix = "nginx-logs/"
    }

    expiration {
      days = var.log_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = var.log_retention_days
    }
  }
}
