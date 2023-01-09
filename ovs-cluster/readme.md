# Create an OVS-compatible K8s Cluster

## Requirements

- Install ansible locally

## Usage

1. Create a `terraform.tfvars` file containing your do_token variable in this directory.
2. Deploy the cluster nodes using `terraform apply`. This will generate the required ansible inventory file aswell
3. Once the cluster has been created you can use the created `kubeconfig` file to access the cluter. Ex `KUBECONFIG=./kubeconfig kubectl get nodes`
