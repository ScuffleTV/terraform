resource "tls_private_key" "redis_ca" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_cert_request" "redis_ca" {
  private_key_pem = tls_private_key.redis_ca.private_key_pem

  subject {
    common_name  = "Scuffle Redis CA"
    organization = "Scuffle"
  }
}

resource "tls_locally_signed_cert" "redis_ca" {
  validity_period_hours = var.validity_period_hours

  cert_request_pem   = tls_cert_request.redis_ca.cert_request_pem
  ca_cert_pem        = tls_self_signed_cert.root_ca.cert_pem
  ca_private_key_pem = tls_private_key.root_ca.private_key_pem

  is_ca_certificate  = true
  set_subject_key_id = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
  ]
}

