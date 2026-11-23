export SELF ?= $(MAKE)

SHELL := /bin/bash
.SHELLFLAGS += -e
.ONESHELL:

upgrade ?= false
region_code ?= use1
directory ?= $(@F)
aws_workspace ?= $(aws_account)-$(directory)
aws_account ?= management
aws_profile ?= $(aws_account)
refresh_only ?= false

## Run terraform init on aws directory
aws/init/%:
	cd aws/$(@F) && \
		export AWS_DEFAULT_PROFILE=$(aws_profile) && \
		export TF_WORKSPACE=$(aws_workspace) && \
		terraform init -backend-config="workspaces/$(aws_workspace).hcl" -reconfigure -upgrade=$(upgrade)

## Run terraform plan on aws directory
aws/plan/%:
	cd aws/$(@F) && \
		export AWS_DEFAULT_PROFILE=$(aws_profile) && \
		export TF_CLI_ARGS_plan="-compact-warnings" && \
		export TF_WORKSPACE=$(aws_workspace) && \
		terraform plan -var-file="${HOME}/tfvars/$(aws_account)/$(directory).tfvars" -refresh-only=$(refresh_only)

## Run terraform apply on aws directory
aws/apply/%:
	cd aws/$(@F) && \
		export AWS_DEFAULT_PROFILE=$(aws_profile) && \
		export TF_WORKSPACE=$(aws_workspace) && \
		terraform apply -var-file="${HOME}/tfvars/$(aws_account)/$(directory).tfvars" -refresh-only=$(refresh_only)

## Run terraform apply on specific resource in an aws directory
aws/apply/target: aws/workspace
	cd aws/$(directory) && \
		aws-vault exec beanbot -- terraform apply -var-file="${HOME}/tfvars/$(aws_account)/$(directory).tfvars" -target=$(target)

## Run terraform destroy on aws directory
aws/destroy/%:
	cd aws/$(@F) && \
		export AWS_DEFAULT_PROFILE=$(aws_profile) && \
		export TF_WORKSPACE=$(aws_workspace) && \
		terraform destroy -var-file="${HOME}/tfvars/$(aws_account)/$(directory).tfvars"

## Run terraform destroy on aws directory
aws/validate: aws/workspace
	cd aws/$(directory) && terraform validate

## Run terraform workspace select
aws/workspace/%:
	cd aws/$(directory) && \
		terraform workspace select $(aws_workspace)

## Run terraform workspace list
aws/workspace/list: aws/init
	cd aws/$(directory) && \
		terraform workspace list

## Run terraform providers lock on aws directory
aws/lock/%:
	cd aws/$(@F) && \
		export AWS_DEFAULT_PROFILE=$(aws_profile) && \
		export TF_WORKSPACE=$(aws_workspace) && \
		terraform init -backend-config="workspaces/$(aws_workspace).hcl" -reconfigure -upgrade=true && \
		terraform providers lock -platform=darwin_amd64 -platform=linux_amd64

## List resources in terraform state. Example: make aws/state/list directory=eks env=load
aws/state/list: aws/workspace
	cd aws/$(directory) && \
		terraform state list
