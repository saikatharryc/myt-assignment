variable "my_app" {
  description = "My app configuration"
  type = object({
    namespace       = optional(string, "default")
    release_version = optional(string, "latest")
    replica_count   = optional(string, "1")
    tolerations = optional(list(object({
      key      = string
      operator = string
      value    = string
      effect   = string
    })), [])
    annotations = optional(map(string), {})
    enable_ingress = optional(string, "false")
  })
}

variable "my_app_secret" {
  description = "My app configuration secrets"
  sensitive   = true
  type = object({
    secret_key  = string
    db_password = string
  })
  default = {
    db_password = "value"
    secret_key  = "value"
  }
}
