resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "helm_release" "prometheus" {
  depends_on = [kubernetes_namespace.monitoring]

  name       = "prometheus"
  namespace  = var.namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = var.prometheus_chart_version

  values = [
    yamlencode({
      alertmanager = { enabled = true }
      server = {
        service = { type = "ClusterIP" }
      }
      pushgateway = { enabled = true }
    })
  ]
}


resource "kubernetes_config_map" "grafana_datasource" {

  metadata {
    name      = "grafana-datasource"
    namespace = var.namespace
    labels = {
      grafana_datasource = "1"  # Ensuring correct label
    }
  }

  data = {
    "prometheus-datasource.yaml" = <<EOF
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    url: http://prometheus-server.${var.namespace}.svc.cluster.local
    access: proxy
    isDefault: true
    editable: true
EOF
  }
}

resource "helm_release" "grafana" {
  depends_on = [kubernetes_namespace.monitoring, kubernetes_config_map.grafana_datasource]

  name       = "grafana"
  namespace  = var.namespace
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = var.grafana_chart_version

  values = [
    yamlencode({
      adminPassword = var.grafana_admin_password
      service       = { type = "ClusterIP" }
      persistence   = { enabled = false }  # Set to true if you need persistent storage
      ingress       = { 
        enabled = true
        annotations = {
          "kubernetes.io/ingress.class" = "nginx"
        }
        hosts = ["grafana.example.com"]
      }
      sidecar = {
        dashboards = {
          enabled            = true
          label              = "grafana_dashboard"
          searchNamespace    = var.namespace
        }
        datasources = {
          enabled          = true
          label            = "grafana_datasource"
          searchNamespace  = var.namespace
        }
      }
      # Use the correct Helm values for grafana configuration
      auth = {
        anonymous = {
          enabled = true
        }
      }
      log = {
        level = "debug"
        mode  = "console"
      }
    })
  ]
}




resource "helm_release" "kube_state_metrics" {
  depends_on = [kubernetes_namespace.monitoring]

  name       = "kube-state-metrics"
  namespace  = var.namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-state-metrics"
  version    = var.kube_state_metrics_chart_version
}




resource "kubernetes_config_map" "grafana_dashboards" {
  depends_on = [helm_release.grafana]

  for_each = var.grafana_dashboards

  metadata {
    name      = replace(each.key, "/", "-")  # Convert dashboard name to valid configmap name
    namespace = var.namespace
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "dashboard.json" = file("${path.module}/dashboards/${each.key}.json")
  }
}
