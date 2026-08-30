# Assignment requirement: an EC2 IAM role and instance profile.
resource "aws_iam_role" "web" {
  name = "${local.name_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${local.name_prefix}-ec2-role"
  }
}

resource "aws_iam_policy" "nginx_log_backup" {
  name        = "${local.name_prefix}-nginx-log-backup"
  description = "Least-privilege access for the web server to archive Nginx logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadBucketMetadata"
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.logs.arn
        Condition = {
          StringLike = {
            "s3:prefix" = [
              "nginx-logs",
              "nginx-logs/*"
            ]
          }
        }
      },
      {
        Sid      = "WriteNginxLogArchives"
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.logs.arn}/nginx-logs/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "nginx_log_backup" {
  role       = aws_iam_role.web.name
  policy_arn = aws_iam_policy.nginx_log_backup.arn
}

resource "aws_iam_instance_profile" "web" {
  name = "${local.name_prefix}-instance-profile"
  role = aws_iam_role.web.name
}

