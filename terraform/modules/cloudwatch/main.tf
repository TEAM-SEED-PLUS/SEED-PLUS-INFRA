locals {
  ns_ec2 = "AWS/EC2"
  ns_cwa = "CWAgent"
  ns_ebs = "AWS/EBS"
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project}-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [

      # ═══════════════════════════ Web Tier ══════════════════════════════════
      {
        type  = "text"
        x     = 0
        y     = 0
        width = 24
        height = 1
        properties = { markdown = "## Web Tier" }
      },
      {
        type   = "metric"
        x      = 0
        y      = 1
        width  = 6
        height = 6
        properties = {
          title   = "CPU Utilization"
          region  = var.aws_region
          period  = 60
          stat    = "Average"
          view    = "timeSeries"
          metrics = [[local.ns_ec2, "CPUUtilization", "InstanceId", var.web_instance_id]]
        }
      },
      {
        type   = "metric"
        x      = 6
        y      = 1
        width  = 6
        height = 6
        properties = {
          title  = "Network In / Out"
          region = var.aws_region
          period = 60
          stat   = "Average"
          view   = "timeSeries"
          metrics = [
            [local.ns_ec2, "NetworkIn", "InstanceId", var.web_instance_id, { label = "In" }],
            [local.ns_ec2, "NetworkOut", "InstanceId", var.web_instance_id, { label = "Out" }],
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 1
        width  = 6
        height = 6
        properties = {
          title   = "Memory Used %"
          region  = var.aws_region
          period  = 60
          stat    = "Average"
          view    = "timeSeries"
          metrics = [[local.ns_cwa, "mem_used_percent", "InstanceId", var.web_instance_id]]
        }
      },
      {
        type   = "metric"
        x      = 18
        y      = 1
        width  = 6
        height = 6
        properties = {
          title   = "Root Disk Used %"
          region  = var.aws_region
          period  = 60
          stat    = "Average"
          view    = "timeSeries"
          metrics = [[local.ns_cwa, "disk_used_percent", "InstanceId", var.web_instance_id, "path", "/"]]
        }
      },

      # ═══════════════════════════ App Tier ══════════════════════════════════
      {
        type   = "text"
        x      = 0
        y      = 7
        width  = 24
        height = 1
        properties = { markdown = "## App Tier" }
      },
      {
        type   = "metric"
        x      = 0
        y      = 8
        width  = 6
        height = 6
        properties = {
          title   = "CPU Utilization"
          region  = var.aws_region
          period  = 60
          stat    = "Average"
          view    = "timeSeries"
          metrics = [[local.ns_ec2, "CPUUtilization", "InstanceId", var.app_instance_id]]
        }
      },
      {
        type   = "metric"
        x      = 6
        y      = 8
        width  = 6
        height = 6
        properties = {
          title  = "Network In / Out"
          region = var.aws_region
          period = 60
          stat   = "Average"
          view   = "timeSeries"
          metrics = [
            [local.ns_ec2, "NetworkIn", "InstanceId", var.app_instance_id, { label = "In" }],
            [local.ns_ec2, "NetworkOut", "InstanceId", var.app_instance_id, { label = "Out" }],
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 8
        width  = 6
        height = 6
        properties = {
          title   = "Memory Used %"
          region  = var.aws_region
          period  = 60
          stat    = "Average"
          view    = "timeSeries"
          metrics = [[local.ns_cwa, "mem_used_percent", "InstanceId", var.app_instance_id]]
        }
      },
      {
        type   = "metric"
        x      = 18
        y      = 8
        width  = 6
        height = 6
        properties = {
          title   = "Root Disk Used %"
          region  = var.aws_region
          period  = 60
          stat    = "Average"
          view    = "timeSeries"
          metrics = [[local.ns_cwa, "disk_used_percent", "InstanceId", var.app_instance_id, "path", "/"]]
        }
      },

      # ═══════════════════════════ DB Tier ═══════════════════════════════════
      {
        type   = "text"
        x      = 0
        y      = 14
        width  = 24
        height = 1
        properties = { markdown = "## DB Tier" }
      },
      {
        type   = "metric"
        x      = 0
        y      = 15
        width  = 6
        height = 6
        properties = {
          title   = "CPU Utilization"
          region  = var.aws_region
          period  = 60
          stat    = "Average"
          view    = "timeSeries"
          metrics = [[local.ns_ec2, "CPUUtilization", "InstanceId", var.db_instance_id]]
        }
      },
      {
        type   = "metric"
        x      = 6
        y      = 15
        width  = 6
        height = 6
        properties = {
          title  = "Network In / Out"
          region = var.aws_region
          period = 60
          stat   = "Average"
          view   = "timeSeries"
          metrics = [
            [local.ns_ec2, "NetworkIn", "InstanceId", var.db_instance_id, { label = "In" }],
            [local.ns_ec2, "NetworkOut", "InstanceId", var.db_instance_id, { label = "Out" }],
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 15
        width  = 6
        height = 6
        properties = {
          title   = "Memory Used %"
          region  = var.aws_region
          period  = 60
          stat    = "Average"
          view    = "timeSeries"
          metrics = [[local.ns_cwa, "mem_used_percent", "InstanceId", var.db_instance_id]]
        }
      },
      {
        type   = "metric"
        x      = 18
        y      = 15
        width  = 6
        height = 6
        properties = {
          title   = "PG Data Disk Used % (/mnt/pgdata)"
          region  = var.aws_region
          period  = 60
          stat    = "Average"
          view    = "timeSeries"
          metrics = [[local.ns_cwa, "disk_used_percent", "InstanceId", var.db_instance_id, "path", "/mnt/pgdata"]]
        }
      },
      # EBS metrics — attached to DB tier
      {
        type   = "metric"
        x      = 0
        y      = 21
        width  = 8
        height = 6
        properties = {
          title  = "EBS Read / Write Bytes"
          region = var.aws_region
          period = 60
          stat   = "Sum"
          view   = "timeSeries"
          metrics = [
            [local.ns_ebs, "VolumeReadBytes", "VolumeId", var.ebs_volume_id, { label = "Read" }],
            [local.ns_ebs, "VolumeWriteBytes", "VolumeId", var.ebs_volume_id, { label = "Write" }],
          ]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 21
        width  = 8
        height = 6
        properties = {
          title  = "EBS IOPS"
          region = var.aws_region
          period = 60
          stat   = "Sum"
          view   = "timeSeries"
          metrics = [
            [local.ns_ebs, "VolumeReadOps", "VolumeId", var.ebs_volume_id, { label = "Read OPS" }],
            [local.ns_ebs, "VolumeWriteOps", "VolumeId", var.ebs_volume_id, { label = "Write OPS" }],
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 21
        width  = 8
        height = 6
        properties = {
          title   = "EBS Queue Depth"
          region  = var.aws_region
          period  = 60
          stat    = "Average"
          view    = "timeSeries"
          metrics = [[local.ns_ebs, "VolumeQueueLength", "VolumeId", var.ebs_volume_id]]
        }
      },

      # ═══════════════════════════ NAT Instance ══════════════════════════════
      {
        type   = "text"
        x      = 0
        y      = 27
        width  = 24
        height = 1
        properties = { markdown = "## NAT Instance" }
      },
      {
        type   = "metric"
        x      = 0
        y      = 28
        width  = 8
        height = 6
        properties = {
          title   = "CPU Utilization"
          region  = var.aws_region
          period  = 60
          stat    = "Average"
          view    = "timeSeries"
          metrics = [[local.ns_ec2, "CPUUtilization", "InstanceId", var.nat_instance_id]]
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 28
        width  = 8
        height = 6
        properties = {
          title  = "Network In / Out"
          region = var.aws_region
          period = 60
          stat   = "Average"
          view   = "timeSeries"
          metrics = [
            [local.ns_ec2, "NetworkIn", "InstanceId", var.nat_instance_id, { label = "In" }],
            [local.ns_ec2, "NetworkOut", "InstanceId", var.nat_instance_id, { label = "Out" }],
          ]
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 28
        width  = 8
        height = 6
        properties = {
          title   = "Status Check Failed"
          region  = var.aws_region
          period  = 60
          stat    = "Maximum"
          view    = "timeSeries"
          metrics = [[local.ns_ec2, "StatusCheckFailed", "InstanceId", var.nat_instance_id]]
        }
      },
    ]
  })
}
