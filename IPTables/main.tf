resource "digitalocean_kubernetes_cluster" "primary" {
  name = "kumacluster"
  region = "tor1"
  version = "1.25.4-do.0"	

  node_pool {
    name = "default"
    size = "s-1vcpu-2gb"
    node_count = 3
  }
}

resource "helm_release" "kuma" {
   name = "kuma"
   version = "2.0.0"
   chart = "kuma"
   repository = "https://kumahq.github.io/charts"
   wait = false
}
