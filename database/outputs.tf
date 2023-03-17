output "redis_password" {
  value       = random_password.redis.result
  description = "The password for the Redis server."
  sensitive   = true
}

output "redis_host" {
  value       = "redis.${var.redis_namespace}.svc.cluster.local:26379"
  description = "The host for the Redis sentinel."
}

output "postgres_password" {
  value       = random_password.postgres.result
  description = "The password for the Postgres server. You should be able to connect to the database using mTLS without the password."
  sensitive   = true
}

output "postgres_host" {
  value       = "postgres-postgresql.${var.postgres_namespace}.svc.cluster.local:5432"
  description = "The host for the Postgres server."
}
