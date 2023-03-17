variable "postgres_namespace" {
  type        = string
  description = "The namespace to deploy the Postgres server in."
  default     = "postgres"
}

variable "redis_namespace" {
  type        = string
  description = "The namespace to deploy the Redis server in."
  default     = "redis"
}

variable "validity_period_hours" {
  type        = number
  description = "The number of hours for which the certificate is valid."
  default     = 24 * 365 * 5 # 5 years
}
