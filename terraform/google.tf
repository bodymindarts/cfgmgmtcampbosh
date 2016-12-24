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

resource "google_compute_subnetwork" "private-1" {
  name          = "${var.google_network_name}-private-1"
  network       = "${google_compute_network.default.self_link}"
  ip_cidr_range = "${var.network}.1.0/24"
  region        = "${var.google_region}"
}
output "google.subnetwork.private-1" {
  value = "${google_compute_subnetwork.private-1.name}"
}
resource "google_compute_subnetwork" "private-2" {
  name          = "${var.google_network_name}-private-2"
  ip_cidr_range = "${var.network}.2.0/24"
  network       = "${google_compute_network.default.self_link}"
  region        = "${var.google_region}"
}
output "google.subnetwork.private-2.name" {
  value = "${google_compute_subnetwork.private-2.name}"
}
resource "google_compute_subnetwork" "private-3" {
  name          = "${var.google_network_name}-private-3"
  ip_cidr_range = "${var.network}.3.0/24"
  network       = "${google_compute_network.default.self_link}"
  region        = "${var.google_region}"
}
output "google.subnetwork.private-3.name" {
  value = "${google_compute_subnetwork.private-3.name}"
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
