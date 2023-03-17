resource "linode_object_storage_key" "loki_lifecycle" {
  label = "${var.loki_bucket_name}-lifecycle"
}

resource "linode_object_storage_bucket" "loki" {
  label      = var.loki_bucket_name
  cluster    = var.s3_region
  access_key = linode_object_storage_key.loki_lifecycle.access_key
  secret_key = linode_object_storage_key.loki_lifecycle.secret_key

  depends_on = [
    linode_object_storage_key.loki_lifecycle,
  ]

  lifecycle_rule {
    id      = "expiry"
    enabled = true
    expiration {
      days = 30
    }
  }
}

resource "linode_object_storage_key" "loki" {
  label = var.loki_bucket_name

  depends_on = [
    linode_object_storage_bucket.loki,
  ]

  bucket_access {
    bucket_name = var.loki_bucket_name
    cluster     = var.s3_region
    permissions = "read_write"
  }
}

resource "helm_release" "loki" {
  name             = "loki"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "grafana-loki"
  version          = var.loki_chart_version
  namespace        = var.loki_namespace
  create_namespace = true

  depends_on = [
    linode_object_storage_bucket.loki,
    linode_object_storage_key.loki,
    helm_release.prometheus,
  ]

  set {
    name  = "queryScheduler.enabled"
    value = "true"
  }

  set {
    name  = "indexGateway.enabled"
    value = "true"
  }

  set {
    name  = "ruler.enabled"
    value = "true"
  }

  set {
    name  = "ruler.containerSecurityContext.runAsUser"
    value = "0"
  }

  set {
    name  = "ruler.containerSecurityContext.runAsNonRoot"
    value = "false"
  }

  set {
    name  = "volumePermissions.enabled"
    value = "true"
  }

  set {
    name  = "compactor.updateStrategy.type"
    value = "Recreate"
  }

  set {
    name  = "compactor.updateStrategy.rollingUpdate"
    value = "null"
  }

  set {
    name = "loki.configuration"
    value = templatefile("${path.module}/config/loki.yml", {
      s3_bucket_name = linode_object_storage_bucket.loki.label,
      s3_endpoint    = var.s3_endpoint,
      s3_region      = var.s3_region,
      s3_access_key  = linode_object_storage_key.loki.access_key,
      s3_secret_key  = linode_object_storage_key.loki.secret_key,
    })
    type = "string"
  }
}
