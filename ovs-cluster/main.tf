terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.25.2"
    }
    remote = {
      source = "tenstad/remote"
      version = "0.1.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.16.1"
    }
  }
}

# Providers
provider "digitalocean" {
  token = var.do_token
}
provider "tls" {}

resource "tls_private_key" "do-ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "digitalocean_ssh_key" "default" {
  name       = "K8 Cluster"
  public_key = tls_private_key.do-ssh-key.public_key_openssh
}

resource "digitalocean_droplet" "master_nodes" {
  count  = 1
  image  = "ubuntu-22-04-x64"
  name   = "cluster-master-${count.index}"
  region = "tor1"
  size   = "s-2vcpu-4gb"

  ssh_keys = [
      digitalocean_ssh_key.default.id
  ]

  provisioner "remote-exec" {
    inline = ["echo \"SSH READY!\""]

    connection {
      host        = self.ipv4_address
      type        = "ssh"
      user        = "root"
      private_key = tls_private_key.do-ssh-key.private_key_openssh
    }
  }
}

resource "digitalocean_droplet" "worker_nodes" {
  count  = 2
  image  = "ubuntu-22-04-x64"
  name   = "cluster-worker-${count.index}"
  region = "tor1"
  size   = "s-2vcpu-4gb"

  ssh_keys = [
      digitalocean_ssh_key.default.id
  ]

  provisioner "remote-exec" {
    inline = ["echo \"SSH READY!\""]

    connection {
      host        = self.ipv4_address
      type        = "ssh"
      user        = "root"
      private_key = tls_private_key.do-ssh-key.private_key_openssh
    }
  }
}

resource "local_file" "ansible_inventory" {
    content = templatefile("${path.module}/ansible_inventory.tftpl", { masters = digitalocean_droplet.master_nodes, workers = digitalocean_droplet.worker_nodes })
    filename = "${path.module}/inventory/hosts"
}

resource "local_file" "ssh_public_key" {
    content = tls_private_key.do-ssh-key.public_key_openssh
    filename = "${path.module}/id_rsa.pub"
}

resource "local_file" "ssh_private_key" {
    content = tls_private_key.do-ssh-key.private_key_openssh
    filename = "${path.module}/id_rsa"
    file_permission = "0600"
}

resource "null_resource" "provision_cluster" {
    provisioner "local-exec" {
        command = "ansible-playbook -u root -i inventory/hosts --private-key id_rsa -e pub_key=id_rsa.pub cluster-init.yml"
    }
    depends_on = [
      local_file.ansible_inventory
    ]
}

data "remote_file" "kubeconfig" {
  conn {
    host        = digitalocean_droplet.master_nodes.0.ipv4_address
    port        = 22
    user        = "root"
    private_key = tls_private_key.do-ssh-key.private_key_openssh
  }

  depends_on = [
    null_resource.provision_cluster
  ]

  path = "/root/.kube/config"
}

resource "local_file" "kubectl" {
    content = data.remote_file.kubeconfig.content
    filename = "${path.module}/kubeconfig"
    file_permission = "0600"
}

provider "kubernetes" {
  host = yamldecode(data.remote_file.kubeconfig.content)["clusters"][0]["cluster"]["server"]
  client_certificate = base64decode(yamldecode(data.remote_file.kubeconfig.content)["users"][0]["user"]["client-certificate-data"])
  client_key = base64decode(yamldecode(data.remote_file.kubeconfig.content)["users"][0]["user"]["client-key-data"])
  cluster_ca_certificate = base64decode(yamldecode(data.remote_file.kubeconfig.content)["clusters"][0]["cluster"]["certificate-authority-data"])
}

# ####################################################
# Kubernetes stuff goes here
# ####################################################

# resource "kubernetes_namespace" "test_namespace" {
#   metadata {
#     name = "test-namespace"
#   }
# }