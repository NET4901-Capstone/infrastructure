resource "digitalocean_certificate" "cert" {
  name = "kuma"
  type = "lets_encrypt"
  domains = ["kumacluster.com"]
}

resource "digitalocean_kubernetes_cluster" "primary" {
  name = "kumacluster"
  region = "tor1"
  version = "1.25.4-do.0"	
  cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.primary.kube_config[0].cluster_ca_certificate
  )
  node_pool {
    name = "default"
    size = "s-1vcpu-2gb"
    node_count = 3
  }
}
