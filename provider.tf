terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.3.0"
    }
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.22.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.13.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "~> 0.19.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.1.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

provider "kubectl" {
  host  = digitalocean_kubernetes_cluster.primary.endpoint
  token = digitalocean_kubernetes_cluster.primary.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.primary.kube_config[0].cluster_ca_certificate
  )
  load_config_file = false
}

provider "kubernetes" {
  host  = digitalocean_kubernetes_cluster.primary.endpoint
  token = digitalocean_kubernetes_cluster.primary.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.primary.kube_config[0].cluster_ca_certificate
  )
}

provider "github" {
  owner = var.github_user
  token = var.github_token
}