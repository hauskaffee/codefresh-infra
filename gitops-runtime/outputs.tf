output "app_version" {
  description = "App Version Thats Installed"
  value       = helm_release.gitops_runtime.metadata.0.app_version
}

output "helm_chart_version" {
  description = "The Helm Chart Version"
  value       = helm_release.gitops_runtime.metadata.0.version
}

output "status" {
  description = "The Status Of The Helm Chart"
  value       = helm_release.gitops_runtime.status
}

output "post_install_commands" {
  description = "CLI Command For Post Install"
  value       = "cf integration git register default --runtime ${data.terraform_remote_state.aws_infra.outputs.cluster_name} --token $CF_GITHUB_PAT"
}
