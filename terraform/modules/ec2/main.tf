# EC2 module – provisions a single EC2 instance for the given tier.

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = var.key_name
  iam_instance_profile        = var.instance_profile_name
  associate_public_ip_address = var.associate_public_ip_address
  user_data                   = var.user_data

  # Enforce IMDSv2 – prevents SSRF-based credential theft via IMDS
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = {
    Name        = "${var.project}-${var.environment}-${var.tier}"
    Tier        = var.tier
    Environment = var.environment
    Project     = var.project
  }
}
