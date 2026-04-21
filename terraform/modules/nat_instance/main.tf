# NAT Instance module – t4g.nano ARM64 Ubuntu, SSM-only admin access, no SSH.
# OS-level configuration (iptables, ip_forward) is handled by Ansible; this module
# provisions only the cloud resources (EC2, IAM, SG, EIP).

# -----------------------------------------------------------------------------
# AMI – latest Ubuntu 24.04 LTS ARM64 (Canonical official account)
# -----------------------------------------------------------------------------
data "aws_ami" "ubuntu_arm64" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

# -----------------------------------------------------------------------------
# IAM – minimal role: SSM Session Manager only (no S3, CloudWatch, Parameter Store)
# -----------------------------------------------------------------------------
resource "aws_iam_role" "nat" {
  name = "${var.project}-${var.environment}-nat-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = {
    Name        = "${var.project}-${var.environment}-nat-role"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_iam_role_policy_attachment" "nat_ssm_core" {
  role       = aws_iam_role.nat.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "nat" {
  name = "${var.project}-${var.environment}-nat-instance-profile"
  role = aws_iam_role.nat.name

  tags = {
    Name        = "${var.project}-${var.environment}-nat-instance-profile"
    Environment = var.environment
    Project     = var.project
  }
}

# -----------------------------------------------------------------------------
# Security Group – zero-trust: inbound only from private subnets, no SSH, no internet ingress
# -----------------------------------------------------------------------------
resource "aws_security_group" "nat" {
  name        = "${var.project}-${var.environment}-sg-nat"
  description = "NAT instance - HTTP/HTTPS from private subnets only; no internet inbound, no SSH"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project}-${var.environment}-sg-nat"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_vpc_security_group_ingress_rule" "nat_http_from_private" {
  for_each = toset(var.private_subnet_cidrs)

  security_group_id = aws_security_group.nat.id
  description       = "Allow HTTP from private subnet ${each.value}"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "nat_https_from_private" {
  for_each = toset(var.private_subnet_cidrs)

  security_group_id = aws_security_group.nat.id
  description       = "Allow HTTPS from private subnet ${each.value}"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "nat_ssh_admin" {
  security_group_id = aws_security_group.nat.id
  description       = "Allow SSH from operator IP only"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.my_ip
}

resource "aws_vpc_security_group_egress_rule" "nat_http_out" {
  security_group_id = aws_security_group.nat.id
  description       = "Allow HTTP outbound for NAT forwarding to internet"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "nat_https_out" {
  security_group_id = aws_security_group.nat.id
  description       = "Allow HTTPS outbound for NAT forwarding to internet"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

# -----------------------------------------------------------------------------
# EC2 – t4g.nano ARM64; source_dest_check disabled for NAT traffic routing
# No key_name: admin access via SSM Session Manager only
# -----------------------------------------------------------------------------
resource "aws_instance" "nat" {
  ami                         = data.aws_ami.ubuntu_arm64.id
  instance_type               = "t4g.nano"
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.nat.id]
  iam_instance_profile        = aws_iam_instance_profile.nat.name
  source_dest_check           = false # Required – NAT instance must forward packets not addressed to itself
  associate_public_ip_address = false # EIP is used instead of auto-assigned public IP

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }

  tags = {
    Name        = "${var.project}-${var.environment}-nat"
    Role        = "nat-instance"
    Environment = var.environment
    Project     = var.project
  }
}

# -----------------------------------------------------------------------------
# EIP – stable public IP for outbound NAT traffic
# -----------------------------------------------------------------------------
# trivy:ignore:AVD-AWS-0009
resource "aws_eip" "nat" {
  domain   = "vpc"
  instance = aws_instance.nat.id

  tags = {
    Name        = "${var.project}-${var.environment}-nat-eip"
    Environment = var.environment
    Project     = var.project
  }
}
