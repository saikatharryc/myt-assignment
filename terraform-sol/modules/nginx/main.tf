

resource "helm_release" "nginx-ingress" {
  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.nginx_release_version
  namespace        = "default"
  create_namespace = false

  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }
  set {
    name  = "controller.podAnnotations.prometheus\\.io/port"
    value = "10254"
    type  = "string"
  }

  set {
    name  = "controller.podAnnotations.prometheus\\.io/scrape"
    value = "true"
    type  = "string"
  }
}