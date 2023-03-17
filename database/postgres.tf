resource "kubernetes_namespace" "postgres" {
  metadata {
    name = var.postgres_namespace
  }
}

resource "kubectl_manifest" "postgres_server_cert" {
  depends_on = [
    kubernetes_namespace.postgres,
  ]

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "postgres-server"
      namespace = var.postgres_namespace
    }
    spec = {
      secretName = "postgres-server-tls"

      duration    = "2160h" # 90 days
      renewBefore = "720h"  # 30 days

      subject = {
        organization = [
          "Scuffle"
        ]
      }
      commonName = "postgres-postgresql-ha-pgpool"
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

      dnsNames = [
        "postgres-postgresql",
        "postgres-postgresql-hl",
        "*.postgres-postgresql-hl",
        "postgres-postgresql.${var.postgres_namespace}.svc",
        "postgres-postgresql-hl.${var.postgres_namespace}.svc",
        "*.postgres-postgresql-hl.${var.postgres_namespace}.svc",
        "postgres-postgresql.${var.postgres_namespace}.svc.cluster.local",
        "postgres-postgresql-hl.${var.postgres_namespace}.svc.cluster.local",
        "*.postgres-postgresql-hl.${var.postgres_namespace}.svc.cluster.local",
        "localhost", # For the metrics probe
      ]

      issuerRef = {
        name = "postgres-ca"
        kind = "ClusterIssuer"
      }
    }
  })
}

resource "kubectl_manifest" "postgres_client_cert" {
  depends_on = [
    kubernetes_namespace.postgres,
  ]

  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "postgres-client"
      namespace = var.postgres_namespace
    }
    spec = {
      secretName = "postgres-client-tls"

      duration    = "2160h" # 90 days
      renewBefore = "720h"  # 30 days

      subject = {
        organization = [
          "Scuffle"
        ]
      }
      commonName = "postgres"
      isCA       = false
      privateKey = {
        algorithm = "ECDSA"
        encoding  = "PKCS8"
        size      = 256
      }
      usages = [
        "client auth"
      ]

      issuerRef = {
        name = "postgres-ca"
        kind = "ClusterIssuer"
      }
    }
  })
}

resource "kubernetes_config_map" "pgadmin_servers" {
  metadata {
    name      = "pgadmin-servers"
    namespace = var.postgres_namespace
  }

  data = {
    "servers.json" = jsonencode({
      "Servers" : {
        "default" : {
          "Name" : "pgpool",
          "Group" : "Servers",
          "Host" : "postgres-postgresql",
          "Port" : 5432,
          "MaintenanceDB" : "postgres",
          "Username" : "postgres",
          "SSLMode" : "verify-full",
          "SSLCert" : "/auth/tls.crt",
          "SSLKey" : "/auth/tls.key",
          "SSLRootCert" : "/auth/ca.crt",
        }
      }
    })
  }
}

resource "kubernetes_secret" "pgadmin" {
  metadata {
    name      = "pgadmin"
    namespace = var.postgres_namespace
  }

  data = {
    PGADMIN_DEFAULT_EMAIL : "db@scuffle.tv"
    PGADMIN_DEFAULT_PASSWORD : "${random_password.postgres.result}"
  }

  type = "Opaque"
}

resource "kubernetes_deployment" "pgadmin" {
  metadata {
    name      = "pgadmin"
    namespace = var.postgres_namespace
  }

  depends_on = [
    kubectl_manifest.postgres_client_cert,
  ]

  spec {
    replicas = 1
    selector {
      match_labels = {
        app : "pgadmin"
      }
    }
    template {
      metadata {
        name      = "pgadmin"
        namespace = var.postgres_namespace
        labels = {
          app : "pgadmin"
        }
      }
      spec {
        volume {
          name = "pgadmin-servers"
          config_map {
            default_mode = "0600"
            name         = kubernetes_config_map.pgadmin_servers.metadata[0].name
          }
        }

        volume {
          name = "pgadmin-tls"
          secret {
            default_mode = "0400"
            secret_name  = "postgres-client-tls"
          }
        }

        container {
          name  = "pgadmin"
          image = "dpage/pgadmin4:6.20"

          security_context {
            run_as_user     = 0
            run_as_group    = 0
            run_as_non_root = false
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.pgadmin.metadata[0].name
            }
          }
          port {
            container_port = 80
            name           = "http"
            protocol       = "TCP"
          }

          volume_mount {
            name       = "pgadmin-servers"
            mount_path = "/pgadmin4/servers.json"
            sub_path   = "servers.json"
            read_only  = true
          }

          startup_probe {
            http_get {
              path = "/"
              port = "http"
            }

            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 5
            success_threshold     = 1
            failure_threshold     = 3
          }

          volume_mount {
            name       = "pgadmin-tls"
            mount_path = "/var/lib/pgadmin/storage/db_scuffle.tv/auth"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "pgadmin" {
  metadata {
    name      = "pgadmin"
    namespace = var.postgres_namespace
  }

  spec {
    selector = {
      app : "pgadmin"
    }

    port {
      name        = "http"
      port        = 80
      target_port = "http"
    }
  }
}

resource "random_password" "postgres" {
  length  = 32
  special = false
}

resource "helm_release" "postgres" {
  name       = "postgres"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  version    = var.postgres_chart_version
  namespace  = var.postgres_namespace

  depends_on = [
    kubectl_manifest.postgres_server_cert,
    kubernetes_namespace.postgres,
  ]

  set {
    name  = "postgresql.password"
    value = random_password.postgres.result
  }

  set {
    name  = "global.postgresql.auth.username"
    value = "postgres"
  }

  set {
    name  = "global.postgresql.auth.password"
    value = random_password.postgres.result
  }

  set {
    name  = "global.postgresql.auth.postgresqlPassword"
    value = random_password.postgres.result
  }

  set {
    name  = "global.postgresql.auth.database"
    value = "postgres"
  }

  set {
    name  = "postgresql.resources.requests.cpu"
    value = var.postgres_replica_cpu
  }

  set {
    name  = "postgresql.resources.requests.memory"
    value = var.postgres_replica_memory
  }

  set {
    name  = "postgresql.resources.limits.cpu"
    value = var.postgres_replica_cpu
  }

  set {
    name  = "postgresql.resources.limits.memory"
    value = var.postgres_replica_memory
  }

  set {
    name  = "tls.enabled"
    value = "true"
  }

  set {
    name  = "tls.certificatesSecret"
    value = "postgres-server-tls"
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
}
