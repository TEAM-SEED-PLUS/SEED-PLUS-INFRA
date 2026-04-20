# EBS module – gp3 data volume with backup tag, attached to the DB instance.

resource "aws_ebs_volume" "this" {
  availability_zone = var.availability_zone
  type              = "gp3"
  size              = 50
  encrypted         = true

  tags = {
    Name        = "${var.project}-${var.environment}-db-data"
    Backup      = "true" # DLM snapshot policy targets volumes with this tag
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_volume_attachment" "this" {
  device_name = "/dev/xvdb"
  volume_id   = aws_ebs_volume.this.id
  instance_id = var.instance_id
}
