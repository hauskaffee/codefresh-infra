data "terraform_remote_state" "aws_infra" {
  backend = "remote"
  config = {
    organization = "hauskaffee"
    workspaces = {
      name = "aws-infra"
    }
  }
}

resource "helm_release" "classic_runtime" {
  name             = "cf-classic-runtime"
  repository       = "oci://quay.io/codefresh"
  chart            = "cf-runtime"
  version          = "6.3.3"
  namespace        = "cf-classic"
  create_namespace = true
  timeout          = 600
  wait_for_jobs    = true

  set_sensitive {
    name  = "global.codefreshToken"
    value = var.codefresh_token
  }

  set_sensitive {
    name  = "global.accountId"
    value = var.codefresh_account
  }

  set {
    name  = "global.context"
    value = lower("${data.terraform_remote_state.aws_infra.outputs.cluster_name}")
  }

  set {
    name  = "global.agentName"
    value = lower("${data.terraform_remote_state.aws_infra.outputs.cluster_name}")
  }

}
