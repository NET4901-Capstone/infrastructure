# Project Infrastructure
---
1. Generate a Digital Ocean token from the [Digital Ocean website](https://cloud.digitalocean.com/account/api/tokens)
2. Generate a Github Person Access Token from [this page](https://github.com/settings/tokens)
2. Create a file named `terraform.tfvars` with the following content:
```
do_token = "<your-token>"
github_token = "<github-pat>"

```
3. Run `terraform apply` to create the cluster
4. DO NOT FORGET TO RUN `terraform destroy` WHEN YOU ARE DONE. The `flux-system` namespace may get stuck in `terminating` in some cases. Use the fluxcli and run `flux uninstall` to manually remove the namespace.

## Pro-Tips
- We can store the configs for multiple clusters in the same repository and choose which one to deploy. Run `terraform apply -var="cluster_name=<cluster-name>"` to create a new cluster or deploy an existing one
- Install the [Digital Ocean CLI](https://github.com/digitalocean/doctl) and run `doctl kubernetes cluster kubeconfig save` to save the kubeconfig to your machine and be able to use kubectl.