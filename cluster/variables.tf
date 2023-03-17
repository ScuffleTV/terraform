variable "k8s_version" {
  type        = string
  description = "The Kubernetes version to use for the cluster."
  default     = "1.25"
}

variable "region" {
  type        = string
  description = "The region to deploy the cluster in."
  default     = "us-east"
}

variable "control_plane_high_availability" {
  type        = bool
  description = "Whether to deploy the control plane with high availability."
  default     = false
}

variable "tags" {
  type        = list(string)
  description = "Tags to apply to the cluster."
  default     = []
}

variable "label" {
  type        = string
  description = "The label to apply to the cluster."
}

variable "pools" {
  type = list(object({
    count = number
    type  = string
    autoscaler = optional(object({
      min = number
      max = number
    }))
  }))
  description = "The pools to deploy in the cluster."
}
