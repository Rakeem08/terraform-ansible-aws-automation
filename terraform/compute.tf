# Assignment requirement: an EC2 instance.
resource "aws_key_pair" "web" {
  key_name   = "${local.name_prefix}-key"
  public_key = file(pathexpand(var.public_key_path))

  tags = {
    Name = "${local.name_prefix}-key"
  }
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  key_name                    = aws_key_pair.web.key_name
  iam_instance_profile        = aws_iam_instance_profile.web.name
  associate_public_ip_address = true
  monitoring                  = true

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = var.root_volume_size
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "${local.name_prefix}-web"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_eip" "web" {
  domain   = "vpc"
  instance = aws_instance.web.id

  tags = {
    Name = "${local.name_prefix}-web-eip"
  }
}

