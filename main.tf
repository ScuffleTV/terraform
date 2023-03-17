terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "scuffle"

    workspaces {
      prefix = "scuffle-infra-"
    }
  }
}

locals {
  workspace = trimprefix(terraform.workspace, "scuffle-infra-")
}

module "cluster" {
  source = "./cluster"

  control_plane_high_availability = local.workspace == "prod"
  label                           = "scuffle-${local.workspace}"
  pools = [{
    count = 3
    type  = "g6-standard-4"
    autoscaler = {
      min = 3
      max = 6
    }
  }]
}

module "tls" {
  source = "./tls"
}

module "monitoring" {
  source            = "./monitoring"
  loki_bucket_name  = "scuffle-${local.workspace}-loki"
  mimir_bucket_name = "scuffle-${local.workspace}-mimir"
  s3_endpoint       = "us-east-1.linodeobjects.com"
  s3_region         = "us-east-1"

  depends_on = [
    module.cluster,
  ]
}

module "cert_manager" {
  source = "./cert_manager"

  cloudflare_api_token = var.cloudflare_api_token
  root_ca_cert         = module.tls.root_ca_cert

  redis_ca_cert = module.tls.redis_ca_cert
  redis_ca_key  = module.tls.redis_ca_key

  postgres_ca_cert = module.tls.postgres_ca_cert
  postgres_ca_key  = module.tls.postgres_ca_key

  depends_on = [
    module.cluster,
    module.monitoring,
  ]
}


module "database" {
  source           = "./database"
  redis_ca_cert    = module.tls.redis_ca_cert
  postgres_ca_cert = module.tls.postgres_ca_cert

  depends_on = [
    module.cluster,
    module.monitoring,
    module.cert_manager,
  ]
}

module "nginx_ingress" {
  source = "./nginx_ingress"

  depends_on = [
    module.cluster,
  ]
}

module "external_dns" {
  source = "./external_dns"

  cloudflare_api_token = var.cloudflare_api_token

  depends_on = [
    module.cluster,
  ]
}
