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

variable "release_name" {
  type        = string
  description = "The name of the Helm release."
}

variable "namespace" {
  type        = string
  description = "The Kubernetes namespace where the Helm chart will be deployed."
}

variable "chart_path" {
  type        = string
  description = "The local path to the Helm chart."
}

variable "values_file_override" {
  description = "YAML file containing Helm chart override values"
  type        = string
  default     = ""
}

variable "values_override" {
  description = "Override values for the Helm chart"
  type        = map(any)
  default     = {}
}

variable "secret_key" {
  description = "Secret key for the application"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password for the application"
  type        = string
  sensitive   = true
}

variable "tolerations" {
  description = "Tolerations for the app"
  type = list(object({
    key      = string
    operator = string
    value    = string
    effect   = string
  }))
  default = []
}

variable "annotations" {
  description = "Annotations for the app"
  type        = map(string)
  default     = {}
}
