data "terraform_remote_state" "aws_infra" {
  backend = "remote"
  config = {
    organization = "hauskaffee"
    workspaces = {
      name = "aws-infra"
    }
  }
}

resource "codefresh_project" "luke-cf" {
  name = "luke-cf"
  tags = [
    "owner:luke",
    "terraform"
  ]
}

resource "codefresh_pipeline" "example-homepage" {

  name = "${codefresh_project.luke-cf.name}/example-homepage"
  tags = [
    "terraform",
    "project"
  ]

  spec {
    concurrency = 1

    spec_template {
      repo     = "hauskaffee/codefresh-example-homepage"
      path     = "./ci/codefresh.yaml"
      revision = "main"
      context  = "hauskaffee"
    }

    trigger {
      branch_regex        = "/^((main)$).*/gi"
      context             = "hauskaffee"
      description         = "Git Commit On Main excluding CD"
      name                = "Commit_On_Main"
      events              = ["push.heads"]
      modified_files_glob = "!{cd/**,helm/**}"
      provider            = "github"
      repo                = "hauskaffee/codefresh-example-homepage"
      type                = "git"
      disabled = true
    }

    # Need to Apply Trigger First before using cron_trigger. As you need to get the ID of the trigger.
    cron_trigger {
      expression     = "0 16 ? * MON"
      message        = "Weekly at 4pm UTC"
      name           = "Weekly"
      git_trigger_id = "6570f80c75be8c5abb413484"
      branch         = "main"
      disabled = true
    }

    runtime_environment {
      name = "${data.terraform_remote_state.aws_infra.outputs.cluster_name}/cf-classic"
    }

    variables = {
      SLACK_WEBHOOK_URL = "https://hooks.slack.com/triggers/EXAMPLE"
    }
  }

}