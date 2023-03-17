variable "namespace" {
  description = "The namespace to deploy the Nginx Ingress Controller to."
  default     = "nginx-ingress"
}

variable "chart_version" {
  description = "The version of the Nginx Ingress Controller Helm chart to use."
  default     = "9.4.0"
}

variable "prometheus_namespace" {
  description = "The namespace to where Prometheus is deployed to."
  default     = "prometheus"
}

variable "prometheus_scrape_interval" {
  description = "The interval at which Prometheus should scrape metrics."
  default     = "10s"
}
