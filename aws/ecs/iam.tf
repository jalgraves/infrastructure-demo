# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+


data "aws_iam_policy_document" "ecs_task_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "secrets_read_only" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecrets",
      "secretsmanager:GetResourcePolicy"
    ]

    resources = [
      "arn:aws:secretsmanager:${local.configs.region}:${local.account_id}:secret:*"
    ]
  }
  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]

    resources = [
      "arn:aws:kms:${local.configs.region}:${local.account_id}:key/aws/secretsmanager"
    ]
  }
}

resource "aws_iam_policy" "secrets_policy" {
  name   = "secrets-manager-read-only"
  policy = data.aws_iam_policy_document.secrets_read_only.json
}
