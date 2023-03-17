variable "postgres_namespace" {
  description = "The namespace to deploy Postgres to."
  default     = "postgres"
}

variable "postgres_chart_version" {
  description = "The version of the Postgres chart to use."
  default     = "12.2.5"
}

variable "postgres_ca_cert" {
  description = "The certificate for the Postgres CA."
  type        = string
}

variable "postgres_replica_count" {
  description = "The number of replicas to deploy."
  default     = 3
}

variable "postgres_replica_cpu" {
  description = "The CPU to allocate to each replica."
  default     = "1500m"
}

variable "postgres_replica_memory" {
  description = "The memory to allocate to each replica."
  default     = "2Gi"
}

variable "redis_namespace" {
  description = "The namespace to deploy Redis to."
  default     = "redis"
}

variable "redis_chart_version" {
  description = "The version of the Redis chart to use."
  default     = "17.9.0"
}

variable "redis_ca_cert" {
  description = "The certificate for the Redis CA."
  type        = string
}

variable "redis_replica_count" {
  description = "The number of replicas to deploy."
  default     = 3
}

variable "redis_replica_cpu" {
  description = "The CPU to allocate to each replica."
  default     = "300m"
}

variable "redis_replica_memory" {
  description = "The memory to allocate to each replica."
  default     = "1Gi"
}

variable "prometheus_namespace" {
  description = "The namespace Prometheus is deployed to."
  default     = "prometheus"
}

variable "prometheus_scrape_interval" {
  description = "The interval at which Prometheus should scrape metrics."
  default     = "10s"
}
