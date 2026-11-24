# infrastructure-demo

Terraform examples and infrastructure for a multi-account, multi-region AWS environment.

## Architecture Documents

- [AWS Infrastructure Design](aws/INFRASTRUCTURE.md): organization, regional VPCs, ECS/API Gateway, Route 53 failover, Aurora, residency goals, and current implementation caveats.
- [End-to-End API Request Flow](aws/REQUEST_FLOW.md): target-state request path, regional failover behavior, and data-residency boundaries.
- [Infrastructure Design Video Script](aws/VIDEO_SCRIPT.md): a timed 7–8 minute walkthrough of the design, tradeoffs, implementation status, and validation plan.

## Repository Layout

| Path | Purpose |
| --- | --- |
| `aws/organization/` | AWS Organization, organizational units, member accounts, and region SCPs. |
| `aws/vpc/` | Workspace-driven regional VPCs, subnetting, routing, security groups, and cross-account VPC peering. |
| `aws/ecs/` | Regional ECS/Fargate services, ECR image references, ALB ingress, and API Gateway VPC Link. |
| `aws/route53/` | Intended primary/secondary API DNS failover records. |
| `aws/rds/` | Reusable Aurora module and regional database workspace configuration. |
| `adr/` | Architecture decision records. |

The API and data networks are configured as separate Terraform areas. Review the infrastructure design document before assuming the ECS services can currently reach the data VPCs or that all example stacks are ready to apply.

## Prerequisites

- macOS with Homebrew and `asdf` available.
- AWS CLI credentials/profile for the target account.
- Terraform version specified in `.tool-versions`.
- Account-specific Terraform variable files under `~/tfvars/<account>/` and the matching workspace configuration under the stack's `workspaces/` directory.

Run `make help` to see the available project targets. `make setup` installs the project dependencies, Terraform version, pre-commit hooks, and creates the base `~/tfvars` directory.

## Terraform Workflow

For example, to plan the `data-cac1-vpc` workspace:

```sh
make aws/init/vpc aws_account=data-cac1 aws_profile=data-cac1
make aws/plan/vpc aws_account=data-cac1 aws_profile=data-cac1
```

Review the selected AWS profile, workspace, variable file, and complete plan before applying:

```sh
make aws/apply/vpc aws_account=data-cac1 aws_profile=data-cac1
```

The `aws/init/<stack>` target initializes Terraform with the corresponding `workspaces/<workspace>.hcl` backend settings. Planning and applying use `~/tfvars/<account>/<stack>.tfvars`. Confirm both paths match the intended account and environment.

## Current Readiness

The organization and VPC stacks have workspace-specific backend configurations. ECS includes regional Fargate, ALB, and API Gateway resources, but its workspace inputs and resource keys still need alignment. The Route 53 records are incomplete: hosted-zone inputs and health checks are not yet defined. The RDS root still contains example values and needs to consume VPC outputs. These are demonstration materials; validate and complete the affected stack before deployment.
