# EBS module – gp3 data volume with backup tag, attached to the DB instance.
# DLM lifecycle policy snapshots volumes tagged Backup=true daily at 03:00 KST, retaining 7 snapshots.

# -----------------------------------------------------------------------------
# IAM – DLM service role
# -----------------------------------------------------------------------------
resource "aws_iam_role" "dlm" {
  name = "${var.project}-${var.environment}-dlm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "dlm.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.project}-${var.environment}-dlm-role"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_iam_role_policy_attachment" "dlm" {
  role       = aws_iam_role.dlm.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSDataLifecycleManagerServiceRole"
}

# -----------------------------------------------------------------------------
# DLM – daily snapshot at 03:00 KST (18:00 UTC), retain 7
# -----------------------------------------------------------------------------
resource "aws_dlm_lifecycle_policy" "ebs_backup" {
  description        = "Daily EBS snapshot retain 7"
  execution_role_arn = aws_iam_role.dlm.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name      = "daily-3am-kst"
      copy_tags = true

      create_rule {
        cron_expression = "cron(0 18 * * ? *)" # 18:00 UTC = 03:00 KST
      }

      retain_rule {
        count = 7
      }
    }

    target_tags = {
      Backup = "true"
    }
  }

  tags = {
    Name        = "${var.project}-${var.environment}-dlm-policy"
    Environment = var.environment
    Project     = var.project
  }
}

# -----------------------------------------------------------------------------
# EBS – data volume
# -----------------------------------------------------------------------------
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
