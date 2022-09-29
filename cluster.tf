resource "digitalocean_kubernetes_cluster" "cluster-1" {
  name   = "cluster-1"
  region = "tor1"
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.24.4-do.0"

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-2gb"
    node_count = 3
  }
}

output "kubeconfig" {
    value = digitalocean_kubernetes_cluster.cluster-1.kube_config.0
    sensitive = true
}