terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.22.3"
    }
    github = {
      source  = "integrations/github"
      version = ">= 4.5.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.2"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.10.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = ">= 0.0.13"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

module "doks-cluster" {
  source             = "./doks-cluster"
  cluster_name       = "capstone-${var.cluster_name}"
  cluster_region     = "tor1"
  cluster_version    = var.cluster_version

  worker_size        = var.worker_size
  worker_count       = var.worker_count

  providers = {
    digitalocean = digitalocean
  }
}

module "kubernetes-flux" {
  source           = "./kubernetes-flux"
  cluster_name     = module.doks-cluster.cluster_name
  cluster_id       = module.doks-cluster.cluster_id
  github_token     = var.github_token
  github_owner     = "NET4901-Capstone"
  repository_name  = "cluster-config"
  target_path      = "clusters/${var.cluster_name}/base"

  write_kubeconfig = var.write_kubeconfig

  providers = {
    digitalocean = digitalocean
  }
}