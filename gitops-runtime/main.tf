data "terraform_remote_state" "aws_infra" {
  backend = "remote"
  config = {
    organization = "hauskaffee"
    workspaces = {
      name = "aws-infra"
    }
  }
}

resource "helm_release" "gitops_runtime" {
  name             = "cf-gitops-runtime"
  repository       = "oci://quay.io/codefresh"
  chart            = "gitops-runtime"
  version          = "0.3.5"
  namespace        = "cf-gitops"
  create_namespace = true
  timeout          = 600
  wait_for_jobs    = true

  set_sensitive {
    name  = "global.codefresh.userToken.token"
    value = var.codefresh_token
  }

  set_sensitive {
    name  = "global.codefresh.accountId"
    value = var.codefresh_account
  }

  set {
    name  = "global.runtime.name"
    value = lower("${data.terraform_remote_state.aws_infra.outputs.cluster_name}")
  }

  set_sensitive {
    name  = "global.runtime.gitCredentials.username"
    value = var.gh_username
  }

  set_sensitive {
    name  = "global.runtime.gitCredentials.password.value"
    value = var.gh_pat
  }

}
