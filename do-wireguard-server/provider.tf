terraform {
  backend "s3" {
    endpoint = "https://s3.us-west-004.backblazeb2.com"
    bucket = "bitnet-capstone"
    key    = "terraform/state.json"
    region = "us-west-004"
    access_key = "0040b1450c0a9bc0000000006"
    secret_key = "K004OQkXrYDMdXkt3KQY7v9Y0zc9Q9s"
    skip_credentials_validation = true
    skip_region_validation      = true
  }
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.22.3"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.1.0"
    }
    wireguard = {
      source = "OJFord/wireguard"
      version = "0.2.2"
    }
    local = {
      source = "hashicorp/local"
      version = "2.4.0"
    }
  }
}

provider "tls" {}

provider "digitalocean" {
  token = var.do_token
}

provider "cloudflare" {
  api_token = var.cf_token
}
