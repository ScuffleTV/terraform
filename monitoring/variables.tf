variable "grafana_namespace" {
  description = "The namespace to deploy Grafana to."
  default     = "grafana"
}

variable "grafana_chart_version" {
  description = "The version of the Grafana chart to use."
  default     = "8.2.31"
}

variable "prometheus_namespace" {
  description = "The namespace to deploy Prometheus to."
  default     = "prometheus"
}

variable "prometheus_chart_version" {
  description = "The version of the Prometheus chart to use."
  default     = "8.4.1"
}

variable "prometheus_scrape_interval" {
  description = "The interval at which Prometheus should scrape metrics."
  default     = "10s"
}

variable "mimir_namespace" {
  description = "The namespace to deploy Mimir to."
  default     = "mimir"
}

variable "mimir_chart_version" {
  description = "The version of the Mimir chart to use."
  default     = "0.2.2"
}

variable "mimir_bucket_name" {
  description = "The name of the Mimir bucket."
  default     = "mimir"
}

variable "s3_region" {
  description = "The cluster to deploy the Mimir bucket to."
  default     = "us-east-1"
}

variable "loki_namespace" {
  description = "The namespace to deploy Loki to."
  default     = "loki"
}

variable "loki_chart_version" {
  description = "The version of the Loki chart to use."
  default     = "2.6.0"
}

variable "loki_bucket_name" {
  description = "The name of the Loki bucket."
  default     = "loki"
}

variable "s3_endpoint" {
  description = "The endpoint of the s3 bucket."
  type        = string
}
