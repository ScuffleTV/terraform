variable "namespace" {
  description = "The namespace to deploy ExternalDNS to."
  default     = "external-dns"
}

variable "chart_version" {
  description = "The version of the ExternalDNS Helm chart to use."
  default     = "6.14.4"
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
