# Set the variable value in *.tfvars file
variable "cloudflare_email" {}

variable "cloudflare_token" {}

# Configure the Cloudflare provider
provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}

# Set the variable value in *.tfvars file
variable "hcloud_token" {}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = "${var.hcloud_token}"
}
