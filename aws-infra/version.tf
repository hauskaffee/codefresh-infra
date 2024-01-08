terraform {
  required_version = ">= 1.6.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  cloud {
    organization = "hauskaffee"

    workspaces {
      name = "aws-infra"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      owner     = var.owner
      terraform = "true"
      workspace = terraform.workspace
    }
  }
}
