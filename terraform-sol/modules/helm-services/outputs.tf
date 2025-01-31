output "helm_release_name" {
  description = "The name of the Helm release"
  value       = helm_release.app.name
}

output "namespace" {
  description = "The Kubernetes namespace"
  value       = helm_release.app.namespace
}
