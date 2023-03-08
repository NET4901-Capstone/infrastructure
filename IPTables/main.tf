resource "digitalocean_certificate" "cert" {
  name = "kuma"
  type = "lets_encrypt"
  domains = ["kumacluster.com"]
}

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
   chart = "kumahq"
   repository = "https://kumahq.github.io/charts"
   wait = true
}
