variable "namespace" {
  description = "The namespace to deploy CertManager to."
  default     = "cert-manager"
}

variable "grafana_namespace" {
  description = "The namespace that Grafana is deployed to."
  default     = "grafana"
}


variable "cert_manager_chart_version" {
  description = "The version of CertManager Helm chart to use."
  default     = "0.9.3"
}

variable "trust_manager_chart_version" {
  description = "The version of CertManager Helm chart to use."
  default     = "v0.4.0"
}

variable "prometheus_namespace" {
  description = "The namespace to where Prometheus is deployed to."
  default     = "prometheus"
}

variable "prometheus_scrape_interval" {
  description = "The interval at which Prometheus should scrape metrics."
  default     = "10s"
}

variable "cloudflare_api_token" {
  description = "The Cloudflare API token to use."
  sensitive   = true
}

variable "acme_email" {
  description = "The email address to use for ACME."
  default     = "acme@scuffle.tv"
}

variable "root_ca_cert" {
  description = "The root CA certificate to use for Scuffle."
}

variable "redis_ca_cert" {
  description = "The Redis CA certificate to use for Scuffle."
}

variable "redis_ca_key" {
  description = "The Redis CA private key to use for Scuffle."
  sensitive   = true
}

variable "postgres_ca_cert" {
  description = "The Postgres CA certificate to use for Scuffle."
}

variable "postgres_ca_key" {
  description = "The Postgres CA private key to use for Scuffle."
  sensitive   = true
}
