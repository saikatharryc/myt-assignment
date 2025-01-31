provider "helm" {
  kubernetes {
    cluster_ca_certificate = var.cluster_ca_certificate
    host                   = var.cluster_endpoint
    token = var.cluster_sa_token
  }
}

provider "kubernetes" {
  cluster_ca_certificate = var.cluster_ca_certificate
  host = var.cluster_endpoint
  token = var.cluster_sa_token
}
