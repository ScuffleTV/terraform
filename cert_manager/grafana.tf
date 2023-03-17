resource "kubernetes_manifest" "grafana_postgres_tls_auth" {
  depends_on = [
    helm_release.cert_manager,
    kubectl_manifest.postgres_ca_cluster_issuer,
  ]
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "grafana-postgres-tls-auth"
      namespace = var.grafana_namespace
    }
    spec = {
      secretName = "grafana-postgres-tls-auth"
      # this is the name of the user to authenticate as
      commonName = "postgres"
      privateKey = {
        rotationPolicy = "Always"
        algorithm      = "ECDSA"
        size           = 256
        encoding       = "PKCS8"
      }
      usages      = ["client auth"]
      duration    = "360h0m0s" # 15 days
      renewBefore = "180h0m0s" # 7 days
      subject = {
        organizations = ["scuffle"]
      }
      issuerRef = {
        name = "postgres-ca"
        kind = "ClusterIssuer"
      }
    }
  }
}
