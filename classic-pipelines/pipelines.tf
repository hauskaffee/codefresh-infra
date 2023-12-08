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
      context  = "hauskoffee"
    }

    trigger {
      branch_regex        = "/^((main)$).*/gi"
      context             = "hauskoffee"
      description         = "Git Commit On Main excluding CD"
      name                = "Commit_On_Main"
      events              = ["push.heads"]
      modified_files_glob = "!{cd/**,helm/**}"
      provider            = "github"
      repo                = "hauskaffee/codefresh-example-homepage"
      type                = "git"
    }

    cron_trigger {
      expression     = "0 16 ? * MON"
      message        = "Weekly at 4pm UTC"
      name           = "Weekly"
      git_trigger_id = "6570f80c75be8c5abb413484"
      branch         = "main"
    }

    variables = {
      SLACK_WEBHOOK_URL = "https://hooks.slack.com/triggers/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"
    }
  }

}