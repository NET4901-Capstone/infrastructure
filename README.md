# Project Infrastructure
---
1. Generate a token from the [Digital Ocean website](https://cloud.digitalocean.com/account/api/tokens)
2. Create a file named `terraform.tfvars` with the following content:
```
do_token = "<your-token>"
```
3. Run `terraform apply` to create the cluster
4. DO NOT FORGET TO RUN `terraform destroy` WHEN YOU ARE DONE