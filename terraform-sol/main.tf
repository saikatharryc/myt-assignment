data "external" "kubeconfig" {
  program = ["./kubeconfig.sh"]
}


## Ideally this has to stay in a seprate repo if we happen to manage the services via TF below way,
## The reason is we may need to not only have nginx but a lot more stuff, same goes for monitoring components.
## These are core configs for a cluster and should be managed separately from the service configs which changes way often.
module "nginx-ingress" {
  source                 = "./modules/nginx"
  cluster_endpoint       = data.external.kubeconfig.result["endpoint"]
  cluster_ca_certificate = base64decode(data.external.kubeconfig.result["ca_cert"])
  cluster_sa_token       = data.external.kubeconfig.result["token"]
}

module "monitoring" {
  source                 = "./modules/monitoring"
  cluster_endpoint       = data.external.kubeconfig.result["endpoint"]
  cluster_ca_certificate = base64decode(data.external.kubeconfig.result["ca_cert"])
  cluster_sa_token       = data.external.kubeconfig.result["token"]
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
