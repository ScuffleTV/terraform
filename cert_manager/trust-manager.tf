resource "helm_release" "trust_manager" {
  name             = "trust-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "trust-manager"
  version          = var.trust_manager_chart_version
  namespace        = var.namespace
  create_namespace = true
}

resource "kubectl_manifest" "trust_manager_full_bundle" {
  depends_on = [
    helm_release.trust_manager,
  ]
  yaml_body = yamlencode({
    apiVersion = "trust.cert-manager.io/v1alpha1"
    kind       = "Bundle"
    metadata = {
      name = "full-ca-bundle"
    }
    spec = {
      sources = [
        {
          useDefaultCAs = true
        },
        {
          inLine = var.root_ca_cert
        },
        {
          inLine = var.redis_ca_cert
        },
        {
          inLine = var.postgres_ca_cert
        },
      ]

      target = {
        configMap = {
          key = "ca.crt"
        }
      }
    }
  })
}

resource "kubectl_manifest" "trust_manager_redis_bundle" {
  depends_on = [
    helm_release.trust_manager,
  ]
  yaml_body = yamlencode({
    apiVersion = "trust.cert-manager.io/v1alpha1"
    kind       = "Bundle"
    metadata = {
      name = "redis-ca-bundle"
    }
    spec = {
      sources = [
        {
          inLine = var.redis_ca_cert
        },
      ]

      target = {
        configMap = {
          key = "ca.crt"
        }
      }
    }
  })
}

resource "kubectl_manifest" "trust_manager_postgres_bundle" {
  depends_on = [
    helm_release.trust_manager,
  ]
  yaml_body = yamlencode({
    apiVersion = "trust.cert-manager.io/v1alpha1"
    kind       = "Bundle"
    metadata = {
      name = "postgres-ca-bundle"
    }
    spec = {
      sources = [
        {
          inLine = var.postgres_ca_cert
        },
      ]

      target = {
        configMap = {
          key = "ca.crt"
        }
      }
    }
  })
}
