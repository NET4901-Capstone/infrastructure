variable "peers" {
    type = map
    default = {
      cluster = {private_key="EAl/+5IYo6/kKHhVrwVTM/d4qcBiqmQTzzvwrSUf0Go=", ip="10.8.0.2", allowed_ips="10.96.0.0/12"}
      mark_laptop = {private_key="CJTejWk46PKfVTJMAgRyZH9teUAQ+jN5HXrgXGyB1G4=", ip="10.8.0.3", allowed_ips=""}
      mark_phone = {private_key="0Oh4nRcTsFihf29ghmBEMVb3yKO4UzXle+VsqTb0oVA=", ip="10.8.0.4", allowed_ips=""}
      adam = {private_key="OJiSBZrP2dGPZ7LhOSBKXUGt65oKljbylu768Pjymms=", ip="10.8.0.5", allowed_ips=""}
    }
}

variable "do_token" {
  type = string
  sensitive = true
}

variable "cf_token" {
  type = string
  sensitive = true
}

resource "tls_private_key" "do-ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "digitalocean_ssh_key" "default" {
  name       = "Wireguard Server"
  public_key = tls_private_key.do-ssh-key.public_key_openssh
}

resource "wireguard_asymmetric_key" "server_keypair" {
  private_key = "qA+E+jxI27uW/W4SMYxYDamK2R+h2EfWmXOkSSndYkA="
}

resource "wireguard_asymmetric_key" "peer_keypairs" {
  for_each = var.peers
  private_key = each.value.private_key
}

resource "digitalocean_droplet" "wireguard_server" {
  image  = "ubuntu-22-04-x64"
  name   = "wireguard"
  region = "tor1"
  size   = "s-2vcpu-4gb"

  ssh_keys = [
      digitalocean_ssh_key.default.id
  ]
}

resource "null_resource" "provision_wg" {
  provisioner "remote-exec" {
    inline = [
        "apt update",
        "apt -y install wireguard",
        "systemctl stop wg-quick@wg0.service",
        "ufw disable"
    ]

    connection {
      host        = digitalocean_droplet.wireguard_server.ipv4_address
      type        = "ssh"
      user        = "root"
      private_key = tls_private_key.do-ssh-key.private_key_openssh
    }
  }

  provisioner "file" {
    content = templatefile("templates/wg0.conf.tmpl", { 
      priv_key=wireguard_asymmetric_key.server_keypair.private_key, 
      peers = [
        for peer_name, peer in var.peers:
          {
            private_key = peer.private_key,
            public_key = wireguard_asymmetric_key.peer_keypairs[peer_name].public_key
            allowed_ips = peer.allowed_ips != "" ? "${peer.ip},${peer.allowed_ips}" : peer.ip
          }
      ]
    })
    destination = "/etc/wireguard/wg0.conf"

    connection {
      host        = digitalocean_droplet.wireguard_server.ipv4_address
      type        = "ssh"
      user        = "root"
      private_key = tls_private_key.do-ssh-key.private_key_openssh
    }
  }

  provisioner "remote-exec" {
    inline = [
        "systemctl enable wg-quick@wg0.service",
        "systemctl start wg-quick@wg0.service"
    ]

    connection {
      host        = digitalocean_droplet.wireguard_server.ipv4_address
      type        = "ssh"
      user        = "root"
      private_key = tls_private_key.do-ssh-key.private_key_openssh
    }
  }
  triggers = {
    "peers_config" = jsonencode(var.peers)
    # always_run = "${timestamp()}"
  }
}

data "cloudflare_zones" "public_domain" {
  filter {
    name = "kuberbitnetes.xyz"
  }
}

resource "cloudflare_record" "wireguard_vpn" {
  name    = "vpn"
  zone_id = lookup(data.cloudflare_zones.public_domain.zones[0], "id")
  value   = digitalocean_droplet.wireguard_server.ipv4_address
  proxied = false
  type    = "A"
  ttl     = 1
}

resource "local_file" "peer_configs" {
  for_each = var.peers
  content  = templatefile("templates/peer.conf.tmpl", { 
      peer = each.value,
      server = {public_key=wireguard_asymmetric_key.server_keypair.public_key, ip=digitalocean_droplet.wireguard_server.ipv4_address}
  })
  filename = "${path.module}/peer_configs/${each.key}.conf"
}

output "ssh_private_key" {
  value = tls_private_key.do-ssh-key.private_key_openssh
  sensitive = true
}