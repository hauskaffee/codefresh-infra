terraform {
  required_version = ">= 1.6.5"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.1"
    }
  }

  cloud {
    organization = "hauskaffee"

    workspaces {
      name = "gitops-runtimes"
    }
  }
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.aws_infra.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.aws_infra.outputs.cluster_ca_cert)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.aws_infra.outputs.cluster_name]
      command     = "aws"
    }
  }
}
