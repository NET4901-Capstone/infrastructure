variable "cluster_version" {
  default = "1.22"
}

variable "worker_count" {
  default = 3
}

variable "worker_size" {
  default = "s-2vcpu-4gb"
}

variable "write_kubeconfig" {
  type        = bool
  default     = true
}

variable "do_token" {
    type = string
    sensitive = true
}

variable "github_token" {
    type = string
    sensitive = true
}

variable "cluster_name" {
  type = string
  default = "testing"
}