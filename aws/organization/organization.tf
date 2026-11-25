# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+
# |*|*|*|*| |J|A|L|G|R|A|V|E|S| |*|*|*|*|
# +-+-+-+-+ +-+-+-+-+-+-+-+-+-+ +-+-+-+-+

resource "aws_organizations_organization" "this" {
  feature_set = "ALL"
  aws_service_access_principals = [
    "account-access.amazonaws.com",
    "account.amazonaws.com",
    "compute-optimizer.amazonaws.com",
    "cost-optimization-hub.bcm.amazonaws.com",
    "iam.amazonaws.com",
    "notifications.amazonaws.com",
    "sso.amazonaws.com",
    "guardduty.amazonaws.com",
    "servicecatalog.amazonaws.com",
  ]

  enabled_policy_types = [
    "RESOURCE_CONTROL_POLICY",
    "SERVICE_CONTROL_POLICY",
    "GUARDDUTY_POLICY",
    "S3_POLICY"
  ]

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_organizations_organizational_unit" "this" {
  for_each = {
    for ou_name, ou in local.organizational_units : ou_name => ou
  }
  name      = each.key
  parent_id = aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_policy" "region_deny" {
  for_each = {
    for account_name, account in local.accounts : account_name => account
  }
  name        = "${each.key}-deny-unapproved-regions"
  description = "Deny requests outside the approved AWS Regions."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyRequestsOutsideApprovedRegions"
        Effect = "Deny"
        NotAction = [
          "a4b:*",
          "access-analyzer:*",
          "account:*",
          "acm:*",
          "activate:*",
          "artifact:*",
          "aws-marketplace-management:*",
          "aws-marketplace:*",
          "aws-portal:*",
          "billing:*",
          "billingconductor:*",
          "budgets:*",
          "ce:*",
          "chatbot:*",
          "chime:*",
          "cloudfront:*",
          "cloudtrail:LookupEvents",
          "compute-optimizer:*",
          "config:*",
          "consoleapp:*",
          "consolidatedbilling:*",
          "cur:*",
          "datapipeline:GetAccountLimits",
          "devicefarm:*",
          "directconnect:*",
          "ec2:DescribeRegions",
          "ec2:DescribeTransitGateways",
          "ec2:DescribeVpnGateways",
          "ecr-public:*",
          "fms:*",
          "freetier:*",
          "globalaccelerator:*",
          "health:*",
          "iam:*",
          "importexport:*",
          "invoicing:*",
          "iq:*",
          "kms:*",
          "license-manager:ListReceivedLicenses",
          "lightsail:Get*",
          "mobileanalytics:*",
          "networkmanager:*",
          "notifications-contacts:*",
          "notifications:*",
          "organizations:*",
          "payments:*",
          "pricing:*",
          "quicksight:DescribeAccountSubscription",
          "resource-explorer-2:*",
          "route53-recovery-cluster:*",
          "route53-recovery-control-config:*",
          "route53-recovery-readiness:*",
          "route53:*",
          "route53domains:*",
          "s3:CreateMultiRegionAccessPoint",
          "s3:DeleteMultiRegionAccessPoint",
          "s3:DescribeMultiRegionAccessPointOperation",
          "s3:GetAccountPublicAccessBlock",
          "s3:GetBucketLocation",
          "s3:GetBucketPolicyStatus",
          "s3:GetBucketPublicAccessBlock",
          "s3:GetMultiRegionAccessPoint",
          "s3:GetMultiRegionAccessPointPolicy",
          "s3:GetMultiRegionAccessPointPolicyStatus",
          "s3:GetStorageLensConfiguration",
          "s3:GetStorageLensDashboard",
          "s3:ListAllMyBuckets",
          "s3:ListMultiRegionAccessPoints",
          "s3:ListStorageLensConfigurations",
          "s3:PutAccountPublicAccessBlock",
          "s3:PutMultiRegionAccessPointPolicy",
          "savingsplans:*",
          "shield:*",
          "sso:*",
          "sts:*",
          "support:*",
          "supportapp:*",
          "supportplans:*",
          "sustainability:*",
          "tag:GetResources",
          "tax:*",
          "trustedadvisor:*",
          "vendor-insights:ListEntitledSecurityProfiles",
          "waf-regional:*",
          "waf:*",
          "wafv2:*"
        ]

        Resource = "*"

        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = each.value.allowed_regions
          }
        }
      }
    ]
  })
}

resource "aws_organizations_policy_attachment" "region_deny" {
  for_each = {
    for account_name, account in local.accounts : account_name => account
  }
  policy_id = aws_organizations_policy.region_deny[each.key].id
  target_id = aws_organizations_account.this[each.key].id
}
