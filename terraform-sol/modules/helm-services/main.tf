resource "kubernetes_namespace" "app" {
  metadata {
    name = var.namespace
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}


resource "helm_release" "app" {
  depends_on = [ kubernetes_namespace.app ]

  name       = var.release_name
  namespace  = var.namespace
  chart      = var.chart_path

  values = [
    var.values_file_override,
    yamlencode(var.values_override),
    yamlencode({
      "tolerations": var.tolerations
    })
  ]


  set {
    name  = "annotations"
    value = jsonencode(var.annotations)
  }

  set_sensitive {
    name  = "secret.SECRET_KEY"
    value = var.secret_key
  }

  set_sensitive {
    name  = "secret.DB_PASSWORD"
    value = var.db_password
  }
}
