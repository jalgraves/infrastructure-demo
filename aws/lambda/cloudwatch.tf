resource "aws_sns_topic" "network_alerts" {
  name = "network-alerts"
}

resource "aws_cloudwatch_metric_alarm" "eu_connection_failure" {
  alarm_name = "api-use1-to-eu-database-connection-failure"

  alarm_description = <<-EOT
    The scheduled probe cannot connect from the US East API VPC
    to the EU regional database, or its metric is missing.
  EOT

  namespace   = "Protex/Connectivity"
  metric_name = "ConnectionSuccess"

  dimensions = {
    CentralDeployment = "api-use1"
    TargetRegion      = "eu"
  }

  # The probe publishes 1 on success and 0 on failure.
  statistic           = "Minimum"
  period              = 60
  evaluation_periods  = 3
  datapoints_to_alarm = 2
  threshold           = 1
  comparison_operator = "LessThanThreshold"

  # A stopped probe should not appear healthy.
  treat_missing_data = "breaching"

  alarm_actions = [aws_sns_topic.network_alerts.arn]
  ok_actions    = [aws_sns_topic.network_alerts.arn]
}
