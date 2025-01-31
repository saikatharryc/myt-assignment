data "external" "kubeconfig" {
  program = ["./kubeconfig.sh"]
}

## Each of the app can have its own set of modules

module "my_app" {
  source                 = "./modules/helm-services"
  cluster_endpoint       = data.external.kubeconfig.result["endpoint"]
  cluster_ca_certificate = base64decode(data.external.kubeconfig.result["ca_cert"])
  cluster_sa_token       = data.external.kubeconfig.result["token"]
  namespace              = var.my_app.namespace
  tolerations            = var.my_app.tolerations
  annotations            = var.my_app.annotations
  secret_key             = var.my_app_secret.secret_key
  db_password            = var.my_app_secret.db_password
  chart_path             = "../chart"
  release_name           = "my-app"
  release_version        = var.my_app.release_version
  replica_count          = var.my_app.replica_count
  enable_ingress         = var.my_app.enable_ingress
}
