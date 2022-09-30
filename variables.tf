# ======================== DOKS =========================
variable "do_token" {
    type = string
    sensitive = true
}

variable "cluster_name" {
  type = string
  default = "testing"
}

variable "doks_cluster_region" {
  description = "DOKS cluster region"
  type        = string
  default = "tor1"
}

variable "doks_cluster_pool_size" {
  description = "DOKS cluster node pool size"
  type        = string
  default = "s-2vcpu-4gb"
}

variable "doks_cluster_pool_node_count" {
  description = "DOKS cluster worker nodes count"
  type        = number
  default = 3
}

# ========================== GIT ============================

variable "github_token" {
    type = string
    sensitive = true
}

variable "github_user" {
  description = "GitHub owner"
  type        = string
  default = "NET4901-Capstone"
}

variable "github_ssh_pub_key" {
  description = "GitHub SSH public key"
  type        = string
  default     = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
}

variable "git_repository_name" {
  description = "Git main repository to use for installation"
  type        = string
  default = "cluster-config"
}

variable "git_repository_branch" {
  description = "Branch name to use on the Git repository"
  type        = string
  default     = "main"
}

# ========================== MISC ============================
variable "write_kubeconfig" {
  type        = bool
  default     = true
}



