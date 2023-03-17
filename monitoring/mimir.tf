resource "linode_object_storage_key" "mimir_lifecycle" {
  label = "${var.mimir_bucket_name}-lifecycle"
}

resource "linode_object_storage_bucket" "mimir_tsdb" {
  cluster = var.s3_region
  label   = "${var.mimir_bucket_name}-tsdb"

  depends_on = [
    linode_object_storage_key.mimir_lifecycle,
  ]

  access_key = linode_object_storage_key.mimir_lifecycle.access_key
  secret_key = linode_object_storage_key.mimir_lifecycle.secret_key

  lifecycle_rule {
    id      = "mimir-expiry"
    enabled = true
    expiration {
      days = 30
    }
  }
}

resource "linode_object_storage_bucket" "mimir_alertmanager" {
  cluster = var.s3_region
  label   = "${var.mimir_bucket_name}-alertmanager"
}

resource "linode_object_storage_bucket" "mimir_ruler" {
  cluster = var.s3_region
  label   = "${var.mimir_bucket_name}-ruler"
}

resource "linode_object_storage_key" "mimir" {
  label = var.mimir_bucket_name

  depends_on = [
    linode_object_storage_bucket.mimir_tsdb,
    linode_object_storage_bucket.mimir_alertmanager,
    linode_object_storage_bucket.mimir_ruler,
  ]

  bucket_access {
    bucket_name = linode_object_storage_bucket.mimir_tsdb.label
    cluster     = var.s3_region
    permissions = "read_write"
  }

  bucket_access {
    bucket_name = linode_object_storage_bucket.mimir_alertmanager.label
    cluster     = var.s3_region
    permissions = "read_write"
  }

  bucket_access {
    bucket_name = linode_object_storage_bucket.mimir_ruler.label
    cluster     = var.s3_region
    permissions = "read_write"
  }
}

resource "helm_release" "mimir" {
  name             = "mimir"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "grafana-mimir"
  version          = var.mimir_chart_version
  namespace        = var.mimir_namespace
  create_namespace = true

  depends_on = [
    linode_object_storage_bucket.mimir_tsdb,
    linode_object_storage_bucket.mimir_alertmanager,
    linode_object_storage_bucket.mimir_ruler,
    linode_object_storage_key.mimir,
    helm_release.prometheus,
  ]

  set {
    name  = "minio.enabled"
    value = "false"
  }

  set {
    name  = "ruler.enabled"
    value = "true"
  }

  set {
    name  = "alertmanager.enabled"
    value = "true"
  }

  set {
    name  = "metrics.enabled"
    value = "true"
  }

  set {
    name  = "metrics.serviceMonitor.enabled"
    value = "true"
  }

  set {
    name  = "metrics.serviceMonitor.namespace"
    value = var.prometheus_namespace
  }

  set {
    name  = "metrics.serviceMonitor.interval"
    value = var.prometheus_scrape_interval
  }

  set {
    name = "mimir.configuration"
    value = templatefile("${path.module}/config/mimir.yml", {
      s3_tsdb_bucket_name         = linode_object_storage_bucket.mimir_tsdb.label,
      s3_alertmanager_bucket_name = linode_object_storage_bucket.mimir_alertmanager.label,
      s3_ruler_bucket_name        = linode_object_storage_bucket.mimir_ruler.label,
      s3_endpoint                 = var.s3_endpoint,
      s3_region                   = var.s3_region,
      s3_access_key               = linode_object_storage_key.mimir.access_key,
      s3_secret_key               = linode_object_storage_key.mimir.secret_key,
    })
    type = "string"
  }

  set {
    name  = "compactor.containerSecurityContext.runAsUser"
    value = "0"
  }

  set {
    name  = "compactor.containerSecurityContext.runAsNonRoot"
    value = "false"
  }

  set {
    name  = "volumePermissions.enabled"
    value = "true"
  }
}
