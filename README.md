# Codefresh Infra

This is a personal project using terraform to manage aws infrastructure. Also installing the Classic and Gitops Hybrid Runtimes.

## Features

### aws-infra

This directory is for managing AWS infrastructure.  Mainly creating a VPC, EKS Cluster, and aditional items to make those work. Purpose is to create items easily for testing. Also to destroy all items when no longer needed for easier cleanup.

### classic-pipelines

Using terraform to create Codefresh pipelines and projects.

### classic-runtime

Using terraform to install the Classic Runtime via helm.  Depends on aws-infra to be completed first as it relies on the outputs.

### gitops-runtime

Using terraform to install the Gitopes Runtime via helm.  Depends on aws-infra to be completed first as it relies on the outputs. Output will show a codefresh cli commands for post install but can be done via the Codefresh UI.

## How To Use

You will need to have the following installed and configured.

- Terraform CLI
- Terraform Cloud (used for state and sensitive variables)
  - AWS Creds
  - Codefresh Creds
  - GitHub Creds
  - other variables

Deploying Items

- In each directory run `terraform init`
- Then run `terraform apply`
- Run `terraform destroy` when no longer needed.
