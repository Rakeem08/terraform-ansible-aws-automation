variable "aws_region" {
  description = "AWS region used for the deployment."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name used to identify project resources."
  type        = string
  default     = "tech-challenge-3"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "The project name may contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the project VPC."
  type        = string
  default     = "10.30.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public web subnet."
  type        = string
  default     = "10.30.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type for the Nginx web server."
  type        = string
  default     = "t3.micro"
}

variable "ssh_cidr" {
  description = "Trusted public IPv4 CIDR allowed to connect over SSH, for example 203.0.113.10/32."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_cidr)) && var.ssh_cidr != "0.0.0.0/0"
    error_message = "Provide a valid trusted CIDR. SSH access from 0.0.0.0/0 is intentionally prohibited."
  }
}

variable "public_key_path" {
  description = "Local path to the SSH public key Terraform will register with AWS."
  type        = string
  default     = "~/.ssh/tech-challenge-3.pub"
}

variable "private_key_path" {
  description = "Local private-key path written into the generated Ansible inventory output."
  type        = string
  default     = "~/.ssh/tech-challenge-3"
}

variable "root_volume_size" {
  description = "Size in GiB of the encrypted EC2 root volume."
  type        = number
  default     = 10

  validation {
    condition     = var.root_volume_size >= 8
    error_message = "The root volume must be at least 8 GiB."
  }
}

variable "log_retention_days" {
  description = "Number of days before S3 log archives are automatically expired."
  type        = number
  default     = 30
}

variable "force_destroy_bucket" {
  description = "Allow Terraform destroy to remove the lab bucket even when it contains log archives."
  type        = bool
  default     = true
}

