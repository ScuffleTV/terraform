resource "helm_release" "nginx" {
  name             = "nginx-ingress"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "nginx-ingress-controller"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true

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
    name  = "publishService.enabled"
    value = "true"
  }

  set {
    name  = "config.use-proxy-protocol"
    value = "true"
    type  = "string"
  }

  set {
    name  = "config.use-gzip"
    value = "true"
    type  = "string"
  }

  set {
    name  = "config.use-geoip"
    value = "false"
    type  = "string"
  }

  set {
    name  = "config.enable-brotli"
    value = "true"
    type  = "string"
  }

  set {
    name  = "config.use-http2"
    value = "true"
    type  = "string"
  }

  set {
    name  = "config.disable-access-log"
    value = "true"
    type  = "string"
  }

  set {
    name  = "config.force-ssl-redirect"
    value = "true"
    type  = "string"
  }

  set {
    name  = "autoscaling.enabled"
    value = "true"
    type  = "string"
  }

  set {
    name  = "autoscaling.minReplicas"
    value = "3"
  }

  set {
    name  = "autoscaling.maxReplicas"
    value = "10"
  }

  set {
    name  = "autoscaling.targetCPU"
    value = "80"
  }

  set {
    name  = "autoscaling.targetMemory"
    value = "80"
  }

  set {
    name  = "resources.limits.cpu"
    value = "1000m"
  }

  set {
    name  = "resources.limits.memory"
    value = "1024Mi"
  }

  set {
    name  = "resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "resources.requests.memory"
    value = "1024Mi"
  }

  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/linode-loadbalancer-default-proxy-protocol"
    value = "v2"
    type  = "string"
  }

  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/linode-loadbalancer-check-type"
    value = "connection"
    type  = "string"
  }

  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/linode-loadbalancer-check-interval"
    value = "10"
    type  = "string"
  }

  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/linode-loadbalancer-check-timeout"
    value = "5"
    type  = "string"
  }
}
