# Terraform

In order to deploy this state you will need to have terraform installed and configured.

For first time deploying you can use this command:

```bash
terraform init
terraform apply --target "module.cluster"
terraform apply
```

Unfortunately we have to do it in 2 steps because the cluster needs to be deployed before we can deploy the rest of the infrastructure.

The providers depend on each other so you can't deploy them in parallel.
