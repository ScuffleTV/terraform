resource "tls_private_key" "root_ca" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "root_ca" {
  validity_period_hours = var.validity_period_hours

  private_key_pem = tls_private_key.root_ca.private_key_pem

  is_ca_certificate  = true
  set_subject_key_id = true

  subject {
    common_name  = "Scuffle Root CA"
    organization = "Scuffle"
  }

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
  ]
}
