resource "kubernetes_namespace" "redis" {
  metadata {
    name = var.redis_namespace
  }
}

resource "random_password" "redis" {
  length  = 32
  special = false
}

resource "kubectl_manifest" "redis_server_cert" {
  depends_on = [
    kubernetes_namespace.redis,
  ]

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "redis-server"
      namespace = var.redis_namespace
    }
    spec = {
      secretName = "redis-server-tls"

      duration    = "2160h" # 90 days
      renewBefore = "720h"  # 30 days

      subject = {
        organization = [
          "Scuffle"
        ]
      }
      commonName = "redis"
      isCA       = false
      privateKey = {
        algorithm = "ECDSA"
        encoding  = "PKCS8"
        size      = 256
      }
      usages = [
        "server auth",
        "client auth"
      ]

      dns_names = [
        "redis",
        "redis.${var.redis_namespace}",
        "redis-headless",
        "*.redis-headless.${var.redis_namespace}",
        "*.redis-headless",
        "*.redis-headless.${var.redis_namespace}.svc.cluster.local",
        "redis.${var.redis_namespace}.svc.cluster.local",
        "redis-headless.${var.redis_namespace}.svc.cluster.local",
        "localhost", # For the metrics probe
      ]

      issuerRef = {
        name = "redis-ca"
        kind = "ClusterIssuer"
      }
    }
  })
}

resource "helm_release" "redis" {
  name       = "redis"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "redis"
  version    = var.redis_chart_version
  namespace  = var.redis_namespace

  depends_on = [
    kubectl_manifest.redis_server_cert,
    kubernetes_namespace.redis,
  ]

  set {
    name  = "auth.password"
    value = random_password.redis.result
  }

  set {
    name  = "sentinel.enabled"
    value = "true"
  }

  set {
    name  = "tls.enabled"
    value = "true"
  }

  set {
    name  = "tls.existingSecret"
    value = "redis-server-tls"
  }

  set {
    name  = "tls.certFilename"
    value = "tls.crt"
  }

  set {
    name  = "tls.certKeyFilename"
    value = "tls.key"
  }

  set {
    name  = "tls.certCAFilename"
    value = "ca.crt"
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
    name  = "volumePermissions.enabled"
    value = "true"
  }

  set {
    name  = "replica.replicaCount"
    value = var.redis_replica_count
  }

  set {
    name  = "replica.resources.requests.cpu"
    value = var.redis_replica_cpu
  }

  set {
    name  = "replica.resources.requests.memory"
    value = var.redis_replica_memory
  }

  set {
    name  = "replica.resources.limits.cpu"
    value = var.redis_replica_cpu
  }

  set {
    name  = "replica.resources.limits.memory"
    value = var.redis_replica_memory
  }
}
