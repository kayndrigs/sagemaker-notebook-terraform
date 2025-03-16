# SageMaker Environment Terraform Project

## Overview

This project contains Terraform configuration to deploy a fully functional AWS SageMaker environment with associated infrastructure like VPC, subnet, IAM roles, and S3 storage.

## Infrastructure Components

- **SageMaker Domain**: Creates a SageMaker domain with IAM authentication
- **SageMaker User Profile**: Creates a user profile in the domain
- **S3 Bucket**: Creates a versioned S3 bucket for SageMaker artifacts
- **VPC Infrastructure**:
  - Custom VPC with DNS support
  - Subnet in a single availability zone
  - Internet Gateway for external connectivity
  - Route Table for network traffic management
  - Security Group allowing outbound access
- **IAM Resources**: Role with SageMaker full access permissions

## Prerequisites

- Terraform v1.10.5 or later
- AWS CLI configured with appropriate credentials
- AWS account with permissions to create the required resources

## How to Deploy

1. **Initialize the Terraform workspace**:

   ```bash
   terraform init

2. **Review the planned changes**:
   ```bash
   terraform plan


3. **terraform apply**;
   ```bash
   terraform apply

4. terraform destroy**;
   ```bash
   terraform destroy

## Project Structure
`main.tf` - Primary infrastructure definition
`variable.tf` - Variable definitions (e.g., AWS region)
`providers.tf` - AWS provider configuration
`output.tf` - Output values after deployment

## Outputs
After successful deployment, the following information is available:

- SageMaker Domain ID
- SageMaker User Profile name
- S3 Bucket name
