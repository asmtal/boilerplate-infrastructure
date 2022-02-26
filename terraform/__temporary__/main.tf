// temporary (for private network tests only):
resource "google_compute_instance" "gcp_instance" {
  name                      = "instance-1"
  machine_type              = "e2-micro"
  zone                      = "${var.region}-a"
  allow_stopping_for_update = true
  tags                      = ["allow-ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  network_interface {
    subnetwork = var.subnetwork.self_link
    access_config {
    }
  }

  metadata_startup_script = <<SCRIPT
    apt-get update;
    apt-get install -y nmap mysql-client;
  SCRIPT
}

resource "google_compute_firewall" "firewall_rule_ssh" {
  name          = "firewall-rule-ssh"
  network       = var.network.self_link
  target_tags   = ["allow-ssh"]
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
