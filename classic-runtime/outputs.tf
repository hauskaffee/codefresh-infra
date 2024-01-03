output "app_version" {
  description = "App Version Thats Installed"
  value       = helm_release.classic_runtime.metadata.0.app_version
}

output "helm_chart_version" {
  description = "The Helm Chart Version"
  value       = helm_release.classic_runtime.metadata.0.version
}

output "status" {
  description = "The Status Of The Helm Chart"
  value       = helm_release.classic_runtime.status
}
