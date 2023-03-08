resource "digitalocean_certificate" "cert" {
  name = "kuma"
  type = "lets_encrypt"
  domains = ["kumacluster.com"]
}

resource "digitalocean_kubernetes_cluster" "primary" {
  name = "kumacluster"
  region = "tor1"
  version = "1.25.4-do.0"	
  host = data.digitalocean_kubernetes_cluster.primary.endpoint
  cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.primary.kube_config[0].cluster_ca_certificate
  )

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "doctl"
    args = ["kubernetes", "cluster", "kubeconfig", "exec-credential",
    "--version=v1beta1", data.digitalocean_kubernetes_cluster.foo.id]
  }
  node_pool {
    name = "default"
    size = "s-1vcpu-2gb"
    node_count = 3
  }
}
