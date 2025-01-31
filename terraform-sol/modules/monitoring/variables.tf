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

variable "namespace" {
  description = "Namespace to deploy monitoring tools"
  type        = string
  default     = "monitoring"
}

variable "prometheus_chart_version" {
  description = "Version of the Prometheus Helm chart"
  type        = string
  default     = "27.1.0"
}

variable "grafana_chart_version" {
  description = "Version of the Grafana Helm chart"
  type        = string
  default     = "6.59.2"
}

variable "kube_state_metrics_chart_version" {
  description = "Version of the kube-state-metrics Helm chart"
  type        = string
  default     = "5.10.0"
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  sensitive   = true
  default     = "grafana123"
}

variable "grafana_dashboards" {
  description = "Preconfigured Grafana dashboards"
  type        = map(any)
  default = {
    "kubernetes-cluster-monitoring" = "https://grafana.com/grafana/dashboards/18283-kubernetes-dashboard/"
  }
}
