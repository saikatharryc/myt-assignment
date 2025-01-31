variable "my_app" {
  description = "My app configuration"
  type = object({
    namespace   = string
    tolerations = list(object({
      key      = string
      operator = string
      value    = string
      effect   = string
    }))
    annotations = map(string)
  })
  default = {
    namespace   = "apps"
    tolerations = []
    annotations = {}
  }
}

variable "my_app_secret" {
  description = "My app configuration secrets"
  sensitive = true
  type = object({
    secret_key = string
    db_password = string
  })
  default = {
    db_password = "value"
    secret_key = "value"
  }
}
