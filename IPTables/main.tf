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

variable "do_token" {}
provider "digitalocean" {
  token = var.do_token
}

provider "tls" {}

resource "tls_private_key" "do-ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "digitalocean_ssh_key" "cluster_key" {
    name = "K8 Cluster"
    public_key = tls_private_key.do-ssh-key.public_key_openssh
}

resource "digitalocean_kubernetes_cluster" "test-cluster" {
  name = "test-cluster"
  region = "tor1"
  version = "1.23.14-do.0"	

  node_pool {
    name = "default"
    size = "s-1vcpu-2gb"
    node_count = 3
  }
}
provider "kubernetes" {
    host = data.digitalocean_kubernetes_cluster.test-cluster.endpoint
    cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.test-cluster.kube_config[0].cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "doctl"
    args = ["kubernetes", "cluster", "kubeconfig", "exec-credential",
    "--version=v1beta1", data.digitalocean_kubernetes_cluster.test-cluster.id]
    }
}

data "template_file" "cilium" {
  template = file("cilium.yaml")
}

resource "kubernetes_manifest" "cilium" {
  content = data.template_file.cilium.rendered
}

output "cluster-id" {
  value = digitalocean_kubernetes_cluster.test-cluster.id
}
