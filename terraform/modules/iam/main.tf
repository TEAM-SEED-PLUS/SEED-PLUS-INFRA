# IAM module – EC2 instance profile with S3, SSM, and CloudWatch permissions.

data "aws_caller_identity" "current" {}

# -----------------------------------------------------------------------------
# Assume Role Policy – ec2.amazonaws.com only
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# -----------------------------------------------------------------------------
# IAM Role
# -----------------------------------------------------------------------------
resource "aws_iam_role" "ec2" {
  name               = "${var.project}-${var.environment}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name        = "${var.project}-${var.environment}-ec2-role"
    Environment = var.environment
    Project     = var.project
  }
}

# -----------------------------------------------------------------------------
# S3 Policy – ListBucket on bucket + PutObject/GetObject on objects
# ListBucket is required for tools that check object existence before uploading
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "s3_backup" {
  statement {
    sid       = "S3BackupList"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.backup_bucket_name}"]
  }

  statement {
    sid     = "S3BackupAccess"
    effect  = "Allow"
    actions = ["s3:PutObject", "s3:GetObject"]

    resources = [
      "arn:aws:s3:::${var.backup_bucket_name}/*",
    ]
  }
}

resource "aws_iam_policy" "s3_backup" {
  name        = "${var.project}-${var.environment}-s3-backup-policy"
  description = "Allow EC2 to list and read/write objects in the backup S3 bucket"
  policy      = data.aws_iam_policy_document.s3_backup.json

  tags = {
    Name        = "${var.project}-${var.environment}-s3-backup-policy"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_iam_role_policy_attachment" "s3_backup" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.s3_backup.arn
}

# -----------------------------------------------------------------------------
# SSM Policy – GetParameter / GetParameters (Parameter Store read-only)
# account_id is pinned to prevent cross-account parameter access
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "ssm_read" {
  statement {
    sid     = "SSMParameterRead"
    effect  = "Allow"
    actions = ["ssm:GetParameter", "ssm:GetParameters"]

    resources = [
      "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.project}/${var.environment}/*",
    ]
  }
}

resource "aws_iam_policy" "ssm_read" {
  name        = "${var.project}-${var.environment}-ssm-read-policy"
  description = "Allow EC2 to read Parameter Store parameters for this environment"
  policy      = data.aws_iam_policy_document.ssm_read.json

  tags = {
    Name        = "${var.project}-${var.environment}-ssm-read-policy"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_iam_role_policy_attachment" "ssm_read" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ssm_read.arn
}

# -----------------------------------------------------------------------------
# CloudWatch Policy – full set required by CloudWatch Agent
# CreateLogStream / DescribeLogGroups / DescribeLogStreams were previously missing
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "cloudwatch_agent" {
  statement {
    sid    = "CloudWatchMetrics"
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cloudwatch_agent" {
  name        = "${var.project}-${var.environment}-cloudwatch-agent-policy"
  description = "Allow EC2 CloudWatch Agent to publish metrics and logs"
  policy      = data.aws_iam_policy_document.cloudwatch_agent.json

  tags = {
    Name        = "${var.project}-${var.environment}-cloudwatch-agent-policy"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.cloudwatch_agent.arn
}

# -----------------------------------------------------------------------------
# SSM Session Manager – enables SSM Port Forwarding for private tier access
# Attaches the AWS-managed policy; no custom policy needed
# -----------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# -----------------------------------------------------------------------------
# Instance Profile – wraps the role for EC2 attachment
# -----------------------------------------------------------------------------
resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project}-${var.environment}-ec2-instance-profile"
  role = aws_iam_role.ec2.name

  tags = {
    Name        = "${var.project}-${var.environment}-ec2-instance-profile"
    Environment = var.environment
    Project     = var.project
  }
}
