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

resource "helm_release" "prometheus"{
    name = "prometheus-community"
    version = "2.40.5"
    repository = "https://prometheus-community.github.io/helm-charts"
}

resource "helm_release" "nginx" {
    name = "ingress-nginx"
    repository = "https://kubernetes.github.io/ingress-nginx" 
    namespace = "ingress-nginx"
}

module "drupal_helm_deployment" {
  source = "bery/release/helm"
  helm_release_chart = "drupal"
  helm_release_chart = "https://charts.bitnami.com/bitnami"
  helm_release_name = "awesome-drupal"
  helm_release_namespace = "drupal"
  helm_release_description = "Drupal website"

  helm_release_values = {
    drupaEmail = "test@me.com"
  }
}