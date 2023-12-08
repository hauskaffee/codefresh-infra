terraform {
  required_version = ">= 1.6.5"

  required_providers {
    codefresh = {
      source  = "codefresh-io/codefresh"
      version = "0.7.0-beta-1"
    }
  }
  cloud {
    organization = "hauskaffee"

    workspaces {
      name = "pipelines"
    }
  }
}

