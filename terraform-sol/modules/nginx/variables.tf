variable "cluster_ca_certificate" {
  type        = string
  sensitive   = true
  description = "Cluster CA certificate"
}

variable "cluster_endpoint" {
  type        = string
  sensitive   = true
  description = "Cluster endpoint"
}

variable "cluster_sa_token" {
  type        = string
  sensitive   = true
  description = "Cluster SA token"
}

variable "nginx_release_version" {
  type        = string
  description = "The version of the Helm chart to deploy."
  default     = "4.11.3"
}