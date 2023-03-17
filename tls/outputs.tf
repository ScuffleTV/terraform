output "root_ca_cert" {
  value       = tls_self_signed_cert.root_ca.cert_pem
  description = "The root CA certificate."
}

output "redis_ca_cert" {
  value       = tls_locally_signed_cert.redis_ca.cert_pem
  description = "The certificate for the Redis CA."
}

output "redis_ca_key" {
  value       = tls_private_key.redis_ca.private_key_pem_pkcs8
  description = "The private key for the the Redis CA."
  sensitive   = true
}


output "postgres_ca_cert" {
  value       = tls_locally_signed_cert.postgres_ca.cert_pem
  description = "The certificate for the Postgres CA."
}

output "postgres_ca_key" {
  value       = tls_private_key.postgres_ca.private_key_pem_pkcs8
  description = "The private key for the the Postgres CA."
  sensitive   = true
}
