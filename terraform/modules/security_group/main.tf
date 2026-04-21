# Security Group module – defines sg_web, sg_app, and sg_db with least-privilege rules.

# -----------------------------------------------------------------------------
# sg_web – public-facing: HTTP/HTTPS open, SSH restricted to operator IP
# -----------------------------------------------------------------------------
resource "aws_security_group" "web" {
  name        = "${var.project}-${var.environment}-sg-web"
  description = "Security group for web tier"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project}-${var.environment}-sg-web"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_vpc_security_group_ingress_rule" "web_http" {
  security_group_id = aws_security_group.web.id
  description       = "Allow HTTP from anywhere"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "web_https" {
  security_group_id = aws_security_group.web.id
  description       = "Allow HTTPS from anywhere"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "web_ssh" {
  security_group_id = aws_security_group.web.id
  description       = "Allow SSH from operator IP only"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.my_ip
}

resource "aws_vpc_security_group_egress_rule" "web_to_app" {
  security_group_id            = aws_security_group.web.id
  description                  = "Allow outbound to app tier on port 8080"
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
  referenced_security_group_id = aws_security_group.app.id
}

resource "aws_vpc_security_group_egress_rule" "web_ssh_to_app" {
  security_group_id            = aws_security_group.web.id
  description                  = "Allow SSH outbound to app tier for ProxyJump admin access"
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  referenced_security_group_id = aws_security_group.app.id
}

resource "aws_vpc_security_group_egress_rule" "web_ssh_to_db" {
  security_group_id            = aws_security_group.web.id
  description                  = "Allow SSH outbound to DB tier for ProxyJump admin access"
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  referenced_security_group_id = aws_security_group.db.id
}

resource "aws_vpc_security_group_egress_rule" "web_to_db" {
  security_group_id            = aws_security_group.web.id
  description                  = "Allow outbound to DB tier for SSM Port Forwarding relay"
  ip_protocol                  = "tcp"
  from_port                    = var.db_port
  to_port                      = var.db_port
  referenced_security_group_id = aws_security_group.db.id
}

resource "aws_vpc_security_group_egress_rule" "web_https" {
  security_group_id = aws_security_group.web.id
  description       = "Allow HTTPS outbound for OS updates and TLS termination"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "web_http" {
  security_group_id = aws_security_group.web.id
  description       = "Allow HTTP outbound for package repositories"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

# -----------------------------------------------------------------------------
# sg_app – app tier: port 8080 from sg_web only, SSH from operator IP
# -----------------------------------------------------------------------------
resource "aws_security_group" "app" {
  name        = "${var.project}-${var.environment}-sg-app"
  description = "Security group for app tier"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project}-${var.environment}-sg-app"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_8080" {
  security_group_id            = aws_security_group.app.id
  description                  = "Allow app traffic from sg_web only"
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
  referenced_security_group_id = aws_security_group.web.id
}

resource "aws_vpc_security_group_ingress_rule" "app_ssh" {
  security_group_id            = aws_security_group.app.id
  description                  = "Allow SSH from web tier only – admin ProxyJump via Web EC2"
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  referenced_security_group_id = aws_security_group.web.id
}

resource "aws_vpc_security_group_egress_rule" "app_to_db" {
  security_group_id            = aws_security_group.app.id
  description                  = "Allow outbound to DB tier on db_port"
  ip_protocol                  = "tcp"
  from_port                    = var.db_port
  to_port                      = var.db_port
  referenced_security_group_id = aws_security_group.db.id
}

resource "aws_vpc_security_group_egress_rule" "app_https" {
  security_group_id = aws_security_group.app.id
  description       = "Allow HTTPS outbound for external API calls and AWS service endpoints"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "app_http" {
  security_group_id = aws_security_group.app.id
  description       = "Allow HTTP outbound for package repositories"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

# -----------------------------------------------------------------------------
# sg_db – DB tier: PostgreSQL from sg_app only + operator IP, SSH from operator IP
# -----------------------------------------------------------------------------
resource "aws_security_group" "db" {
  name        = "${var.project}-${var.environment}-sg-db"
  description = "Security group for DB tier"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.project}-${var.environment}-sg-db"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_postgres_app" {
  security_group_id            = aws_security_group.db.id
  description                  = "Allow PostgreSQL (non-default port) from sg_app only"
  ip_protocol                  = "tcp"
  from_port                    = var.db_port
  to_port                      = var.db_port
  referenced_security_group_id = aws_security_group.app.id
}

resource "aws_vpc_security_group_ingress_rule" "db_ssh" {
  security_group_id            = aws_security_group.db.id
  description                  = "Allow SSH from web tier only – admin ProxyJump via Web EC2"
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  referenced_security_group_id = aws_security_group.web.id
}

resource "aws_vpc_security_group_ingress_rule" "db_postgres_web" {
  security_group_id            = aws_security_group.db.id
  description                  = "Allow PostgreSQL from web tier for SSM Port Forwarding relay"
  ip_protocol                  = "tcp"
  from_port                    = var.db_port
  to_port                      = var.db_port
  referenced_security_group_id = aws_security_group.web.id
}

resource "aws_vpc_security_group_egress_rule" "db_https" {
  security_group_id = aws_security_group.db.id
  description       = "Allow HTTPS outbound for AWS SSM agent and CloudWatch"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "db_http" {
  security_group_id = aws_security_group.db.id
  description       = "Allow HTTP outbound for package repositories"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}
