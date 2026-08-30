output "instance_id" {
  description = "ID of the EC2 web server."
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Elastic public IPv4 address of the web server."
  value       = aws_eip.web.public_ip
}

output "website_url" {
  description = "Public URL for the required hosted web page."
  value       = "http://${aws_eip.web.public_ip}"
}

output "s3_bucket_name" {
  description = "Name of the encrypted S3 bucket used for Nginx log archives."
  value       = aws_s3_bucket.logs.bucket
}

output "iam_role_name" {
  description = "Least-privilege IAM role attached to the EC2 instance."
  value       = aws_iam_role.web.name
}

output "ssh_command" {
  description = "Command for manually connecting to the EC2 instance."
  value       = "ssh -i ${var.private_key_path} ubuntu@${aws_eip.web.public_ip}"
}

output "ansible_inventory" {
  description = "Inventory content to write to ansible/inventory.ini."
  value       = <<-EOT
    [webservers]
    web ansible_host=${aws_eip.web.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${var.private_key_path}
  EOT
}

