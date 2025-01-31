terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.11.2"
    }
  }
}

provider "helm" {
  kubernetes {
    cluster_ca_certificate = var.cluster_ca_certificate
    host                   = var.cluster_endpoint
    token = var.cluster_sa_token
  }
}

provider "kubectl" {
  cluster_ca_certificate = var.cluster_ca_certificate
  host                   = var.cluster_endpoint
  load_config_file       = false
  token = var.cluster_sa_token
}

provider "kubernetes" {
  cluster_ca_certificate = var.cluster_ca_certificate
  host = var.cluster_endpoint
  token = var.cluster_sa_token
}
