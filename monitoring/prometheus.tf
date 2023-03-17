resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "kube-prometheus"
  version          = var.prometheus_chart_version
  namespace        = var.prometheus_namespace
  create_namespace = true

  set {
    name  = "prometheus.remoteWrite[0].url"
    value = "http://mimir-grafana-mimir-gateway.${var.mimir_namespace}/api/v1/push"
  }

  set {
    name  = "prometheus.alertingEndpoints[0].name"
    value = "mimir-grafana-mimir-gateway"
  }

  set {
    name  = "prometheus.alertingEndpoints[0].namespace"
    value = var.mimir_namespace
  }

  set {
    name  = "prometheus.alertingEndpoints[0].port"
    value = "80"
  }

  set {
    name  = "alertmanager.enabled"
    value = "false"
  }
}
