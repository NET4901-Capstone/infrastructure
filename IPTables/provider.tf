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
    remote = {
      source = "tenstad/remote"
      version = "0.1.1"
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

provider "kubernetes" {
    host = data.digitalocean_kubernetes_cluster.primary.endpoint
    cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.primary.kube_config[0].cluster_ca_certificate)

    client_key = base64decode(data.digitalocean_kubernetes_cluster.primary.kube_config[0].client_key)

    client_certificate = base64decode(data.digitalocean_kubernetes_cluster.primary.kube_config[0].client_certificate)

    exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "doctl"
    args = ["kubernetes", "cluster", "kubeconfig", "exec-credential",
    "--version=v1beta1", data.digitalocean_kubernetes_cluster.test-cluster.id]
    }
}

provider "helm" {
    kubernetes {  
    host = data.digitalocean_kubernetes_cluster.primary.endpoint
    
    cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.primary.kube_config[0].cluster_ca_certificate)
    
    client_key = base64decode(data.digitalocean_kubernetes_cluster.primary.kube_config[0].client_key)
    
    client_certificate = base64decode(data.digitalocean_kubernetes_cluster.primary.kube_config[0].client_certificate)
    }
}
