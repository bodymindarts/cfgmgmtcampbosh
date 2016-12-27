variable "google_project"      { default = "bosh-demo" } # Your Google Region      (required)
variable "google_network_name" { default = "bosh-demo" } # Name of the Network     (required)
variable "google_region"       { default = "europe-west1" } # Google Region           (required)
/* variable "google_zone_1"       {} # Google Zone 1           (required) */
/* variable "google_zone_2"       {} # Google Zone 2           (required) */
/* variable "google_zone_3"       {} # Google Zone 3           (required) */

variable "network"              { default = "10.4" }          # First 2 octets of your /16

provider "google" {
  credentials = "${file("bosh-demo-account.key.json")}"
  project = "${var.google_project}"
  region  = "${var.google_region}"
}

resource "google_compute_address" "bosh" {
  name   = "bosh"
}
output "box.bosh.public_ip" {
  value = "${google_compute_address.bosh.address}"
}

resource "google_compute_network" "default" {
  name = "${var.google_network_name}"
}
output "google.network.name" {
  value = "${google_compute_network.default.name}"
}

resource "google_compute_subnetwork" "infra" {
  name          = "${var.google_network_name}-infra"
  network       = "${google_compute_network.default.self_link}"
  ip_cidr_range = "${var.network}.0.0/24"
  region        = "${var.google_region}"
}
output "google.subnetwork.infra" {
  value = "${google_compute_subnetwork.infra.name}"
}

resource "google_compute_subnetwork" "servers" {
  name          = "${var.google_network_name}-servers"
  network       = "${google_compute_network.default.self_link}"
  ip_cidr_range = "${var.network}.1.0/24"
  region        = "${var.google_region}"
}
output "google.subnetwork.servers" {
  value = "${google_compute_subnetwork.servers.name}"
}
resource "google_compute_subnetwork" "nodes" {
  name          = "${var.google_network_name}-nodes"
  network       = "${google_compute_network.default.self_link}"
  ip_cidr_range = "${var.network}.2.0/24"
  region        = "${var.google_region}"
}
output "google.subnetwork.nodes" {
  value = "${google_compute_subnetwork.nodes.name}"
}

resource "google_compute_firewall" "default" {
  name    = "${var.google_network_name}-default"
  network = "${google_compute_network.default.name}"

  # Allow ICMP traffic
  allow {
    protocol = "icmp"
  }

  # Allow TCP traffic
  allow {
    protocol = "tcp"
  }

  # Allow UDP traffic
  allow {
    protocol = "udp"
  }

  source_ranges = ["0.0.0.0/0"]
  source_tags = ["${var.google_network_name}-default"]
  target_tags = ["${var.google_network_name}-default"]
}

output "google.firewall.default.name" {
  value = "${google_compute_firewall.default.name}"
}

resource "google_compute_address" "servers" {
  name   = "servers"
}
resource "google_compute_forwarding_rule" "servers" {
  name       = "servers"
  target     = "${google_compute_target_pool.servers.self_link}"
  ip_address = "${google_compute_address.servers.address}"
}

output "servers.public_ip" {
  value = "${google_compute_forwarding_rule.servers.ip_address}"
}

resource "google_compute_target_pool" "servers" {
  name = "servers"

  health_checks = [
    "${google_compute_http_health_check.nomad-ui.name}",
  ]
}

output "servers.target_pool" {
  value = "${google_compute_target_pool.servers.name}"
}

resource "google_compute_http_health_check" "nomad-ui" {
  name         = "nomad-ui"
  port = 3000

  timeout_sec        = 1
  check_interval_sec = 1
}

resource "google_compute_address" "nodes" {
  name   = "nodes"
}
resource "google_compute_forwarding_rule" "nodes" {
  name       = "nodes"
  target     = "${google_compute_target_pool.nodes.self_link}"
  ip_address = "${google_compute_address.nodes.address}"
}

output "nodes.public_ip" {
  value = "${google_compute_forwarding_rule.nodes.ip_address}"
}

resource "google_compute_target_pool" "nodes" {
  name = "nodes"

  health_checks = [
    "${google_compute_http_health_check.healthz.name}",
  ]
}

output "nodes.target_pool" {
  value = "${google_compute_target_pool.nodes.name}"
}

resource "google_compute_http_health_check" "healthz" {
  name         = "healthz"
  port = 4567
  request_path = "/_healthz"

  timeout_sec        = 1
  check_interval_sec = 1

  healthy_threshold = 1
  unhealthy_threshold = 1
}
