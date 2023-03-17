output "kubeconfig" {
  value       = module.cluster.kubeconfig
  description = "The kubeconfig for the cluster."
  sensitive   = true
}

output "redis_password" {
  value       = module.database.redis_password
  description = "The password for the Redis server."
  sensitive   = true
}

output "redis_host" {
  value       = module.database.redis_host
  description = "The host for the Redis sentinel."
}

output "postgres_password" {
  value       = module.database.postgres_password
  description = "The password for the Postgres server. You should be able to connect to the database using mTLS without the password."
  sensitive   = true
}

output "postgres_host" {
  value       = module.database.postgres_host
  description = "The host for the Postgres server."
}

output "redis_ca_cert" {
  value       = module.tls.redis_ca_cert
  description = "The certificate for the Redis CA."
}

output "postgres_ca_cert" {
  value       = module.tls.postgres_ca_cert
  description = "The certificate for the Postgres CA."
}

output "root_ca_cert" {
  value       = module.tls.root_ca_cert
  description = "The certificate for the Postgres server."
}
