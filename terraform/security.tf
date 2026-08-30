# Assignment requirement: a security group for the EC2 web server.
resource "aws_security_group" "web" {
  name        = "${local.name_prefix}-web-sg"
  description = "Allow public HTTP and restricted administrative SSH"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-web-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  description       = "Public access to the Nginx website"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.web.id
  description       = "SSH access from the trusted administrator CIDR only"
  cidr_ipv4         = var.ssh_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.web.id
  description       = "Allow package downloads and AWS API access"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

