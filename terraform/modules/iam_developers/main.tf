# Developer IAM module – creates users, groups, and an SSM-scoped policy.
# Access keys are NOT managed here; create them post-apply via:
#   aws iam create-access-key --user-name <username>
# Secrets must not be stored in Terraform state.
#
# Port-level isolation (DB vs App/Web) is enforced by Security Groups on the NAT
# instance, not at the IAM layer (SSM does not support per-port IAM conditions).

data "aws_caller_identity" "current" {}

# -----------------------------------------------------------------------------
# SSM Port Forwarding policy – shared by both groups; NAT instance only
# DB access is blocked at the network layer (sg_db has no rule for sg_nat:db_port)
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "developer_ssm" {
  statement {
    sid    = "SSMStartSessionOnNATOnly"
    effect = "Allow"
    actions = ["ssm:StartSession"]
    resources = [
      "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:instance/${var.nat_instance_id}",
      "arn:aws:ssm:${var.aws_region}::document/AWS-StartPortForwardingSessionToRemoteHost",
      "arn:aws:ssm:${var.aws_region}::document/AWS-StartPortForwardingSession",
    ]
  }

  statement {
    sid    = "SSMManageOwnSessions"
    effect = "Allow"
    actions = [
      "ssm:TerminateSession",
      "ssm:ResumeSession",
    ]
    resources = [
      "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:session/*",
    ]
    condition {
      test     = "StringLike"
      variable = "ssm:resourceTag/aws:ssmmessages:session-id"
      values   = ["$${aws:username}-*"]
    }
  }

  statement {
    sid    = "EC2DescribeForInstanceLookup"
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ssm:DescribeInstanceInformation",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "developer_ssm" {
  name        = "${var.project}-${var.environment}-developer-ssm-policy"
  description = "Allow SSM port-forwarding tunnels to the NAT instance only - no console, no direct EC2 access"
  policy      = data.aws_iam_policy_document.developer_ssm.json

  tags = {
    Name        = "${var.project}-${var.environment}-developer-ssm-policy"
    Environment = var.environment
    Project     = var.project
  }
}

# -----------------------------------------------------------------------------
# Backend Developer Group – App + DB access via NAT (kcw, jhc)
# -----------------------------------------------------------------------------
resource "aws_iam_group" "backend_developers" {
  name = "${var.project}-${var.environment}-backend-developers"
}

resource "aws_iam_group_policy_attachment" "backend_developer_ssm" {
  group      = aws_iam_group.backend_developers.name
  policy_arn = aws_iam_policy.developer_ssm.arn
}

resource "aws_iam_user" "backend_developer" {
  for_each = toset(var.backend_developer_usernames)

  name = each.key
  path = "/${var.project}/${var.environment}/developers/"

  tags = {
    Environment = var.environment
    Project     = var.project
    Role        = "backend-developer"
  }
}

resource "aws_iam_group_membership" "backend_developers" {
  name  = "${var.project}-${var.environment}-backend-developers-membership"
  group = aws_iam_group.backend_developers.name
  users = [for u in aws_iam_user.backend_developer : u.name]
}

# -----------------------------------------------------------------------------
# Frontend Developer Group – App + Web access via NAT only; DB blocked by SG (cjs)
# -----------------------------------------------------------------------------
resource "aws_iam_group" "frontend_developers" {
  name = "${var.project}-${var.environment}-frontend-developers"
}

resource "aws_iam_group_policy_attachment" "frontend_developer_ssm" {
  group      = aws_iam_group.frontend_developers.name
  policy_arn = aws_iam_policy.developer_ssm.arn
}

resource "aws_iam_user" "frontend_developer" {
  for_each = toset(var.frontend_developer_usernames)

  name = each.key
  path = "/${var.project}/${var.environment}/developers/"

  tags = {
    Environment = var.environment
    Project     = var.project
    Role        = "frontend-developer"
  }
}

resource "aws_iam_group_membership" "frontend_developers" {
  name  = "${var.project}-${var.environment}-frontend-developers-membership"
  group = aws_iam_group.frontend_developers.name
  users = [for u in aws_iam_user.frontend_developer : u.name]
}

# -----------------------------------------------------------------------------
# AI Developer Group – DB access via NAT only; App/Web blocked by SG (sjh)
# -----------------------------------------------------------------------------
resource "aws_iam_group" "ai_developers" {
  name = "${var.project}-${var.environment}-ai-developers"
}

resource "aws_iam_group_policy_attachment" "ai_developer_ssm" {
  group      = aws_iam_group.ai_developers.name
  policy_arn = aws_iam_policy.developer_ssm.arn
}

resource "aws_iam_user" "ai_developer" {
  for_each = toset(var.ai_developer_usernames)

  name = each.key
  path = "/${var.project}/${var.environment}/developers/"

  tags = {
    Environment = var.environment
    Project     = var.project
    Role        = "ai-developer"
  }
}

resource "aws_iam_group_membership" "ai_developers" {
  name  = "${var.project}-${var.environment}-ai-developers-membership"
  group = aws_iam_group.ai_developers.name
  users = [for u in aws_iam_user.ai_developer : u.name]
}
