# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

resource "aws_cloudwatch_log_group" "this" {
  for_each = {
    for vpc_name, vpc in local.configs.vpcs : vpc_name => vpc
  }
  name = "${each.key}-flow-logs"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "flow_logs" {
  for_each = {
    for vpc_name, vpc in local.configs.vpcs : vpc_name => vpc
  }
  name               = "${each.key}-flow-logs"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "example" {
  statement {
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

resource "aws_iam_role_policy" "flow_logs" {
  for_each = {
    for vpc_name, vpc in local.configs.vpcs : vpc_name => vpc
  }
  name   = "${each.key}-flow-logs"
  role   = aws_iam_role.flow_logs[each.key].id
  policy = data.aws_iam_policy_document.example.json
}

resource "aws_flow_log" "this" {
  for_each = {
    for vpc_name, vpc in local.configs.vpcs : vpc_name => vpc
  }
  iam_role_arn    = aws_iam_role.flow_logs[each.key].arn
  log_destination = aws_cloudwatch_log_group.this[each.key].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.this[each.key].id
}
