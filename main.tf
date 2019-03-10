variable "cloudflare_zone" {
  default = "doxic.io"
}

#  Main ssh key
resource "hcloud_ssh_key" "default" {
  name       = "main ssh key 2"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "hcloud_server" "node2" {
  name        = "node2"
  image       = "ubuntu-16.04"
  server_type = "cx11"
  ssh_keys    = ["${hcloud_ssh_key.default.name}"]

  labels = {
    "group"       = "webserver"
    "environment" = "dev"
  }

  # provisioner "file" {
  #   source      = "test.txt"
  #   destination = "/tmp/test.txt"
  # }

  # demo_env_cert_body = "${module.acme-cert.certificate_pem}"
  #
  # demo_env_cert_chain = "${module.acme-cert.certificate_issuer_pem}"
  #
  # demo_env_cert_privkey = "${module.acme-cert.certificate_private_key_pem}"

  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo apt-get -y update",
  #     "sudo apt-get -y install nginx",
  #     "sudo sed -i 's/nginx\\!/nginx - instance ${count.index + 1}/g' /var/www/html/index.nginx-debian.html",
  #     "sudo systemctl start nginx",
  #   ]
  # }
}

# Create Hetzner rDNS record
resource "hcloud_rdns" "master" {
  server_id  = "${hcloud_server.node2.id}"
  ip_address = "${hcloud_server.node2.ipv4_address}"
  dns_ptr    = "node2.${var.cloudflare_zone}"
}

# Create Cloudflare DNS record
resource "cloudflare_record" "node2" {
  domain  = "${var.cloudflare_zone}"
  name    = "node2"
  value   = "${hcloud_server.node2.ipv4_address}"
  type    = "A"
  proxied = false
}

# Create SPF DNS record
resource "cloudflare_record" "spf" {
  domain  = "${var.cloudflare_zone}"
  name    = "@"
  value   = "v=spf1 mx ip4:${hcloud_server.node2.ipv4_address} -all"
  type    = "TXT"
  proxied = false
}

# Create DKIM DNS record
resource "cloudflare_record" "dkim" {
  domain  = "${var.cloudflare_zone}"
  name    = "mail._domainkey.${var.cloudflare_zone}"
  value   = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4LWGjKtUQMj0qlPKoVg0UgxNY+btD8AqCc7NSSdY/g/0Ajlv77ZjlUqAo+QEydNr0BZt2xtyUs5kYTYBkyIpHyjcyeThElz5Uney90zwTcVfZZSY++KbiThniHcYUFNQQTEQGCXbwmEZhtbb/owxAng8CClAegeQbKMvXe7wKTaN84lQEJ2E7lL5x115ZHf105O3S7Tdtkq/SjQHH7yxDD2TG2NKQO8wVzxbkQsaJZGt84+y0doQ/UaYnvbmgtbeRtllE7dJj4jR+tuJ85R/uSMhWJKxXXJxSiwl5c4zWZSH0Bwofnfv+wy0HOuU7Hqg5OY6K3bz5x1jgGPJUhxu2QIDAQAB"
  type    = "TXT"
  proxied = false
}

resource "cloudflare_record" "dmarc" {
  domain  = "${var.cloudflare_zone}"
  name    = "_dmarc.${var.cloudflare_zone}"
  value   = "v=DMARC1; p=none; rua=mailto:postmaster@${var.cloudflare_zone}"
  type    = "TXT"
  proxied = false
}

# resource "cloudflare_record" "dkim3" {
#   domain  = "${var.cloudflare_zone}"
#   name    = "mail._domainkey.${var.cloudflare_zone}"
#   value   = "QHH7yxDD2TG2NKQO8wVzxbkQsaJZGt84+y0doQ/UaYnvbmgtbeRtllE7dJj4jR+tuJ85R/uSMhWJKxXXJxSiwl5c4zWZSH0Bwofnfv+wy0HOuU7Hqg5OY6K3bz5x1jgGPJUhxu2QIDAQAB"
#   type    = "TXT"
#   proxied = false
# }

# Create MX DNS record
resource "cloudflare_record" "mx" {
  domain  = "${var.cloudflare_zone}"
  name    = "@"
  value   = "10 node2.${var.cloudflare_zone}"
  type    = "MX"
  proxied = false
}

provider "acme" {
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"

  # server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = "${tls_private_key.private_key.private_key_pem}"
  email_address   = "illfire@gmail.com"
}

resource "acme_certificate" "certificate" {
  account_key_pem = "${acme_registration.reg.account_key_pem}"
  common_name     = "node2.doxic.io"

  # subject_alternative_names = ["node2.doxic.io"]

  dns_challenge {
    provider = "cloudflare"

    config {
      CLOUDFLARE_EMAIL   = "${var.cloudflare_email}"
      CLOUDFLARE_API_KEY = "${var.cloudflare_token}"
    }
  }
}
