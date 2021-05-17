resource "google_service_account" "head-chef" {
  account_id   = "head-chef"
  project = var.project
  display_name = "Chef's Service Account"
}

resource "google_compute_instance" "chef_Workstation" {
  name         = "chef-kitchen"
  machine_type = var.machine_type
  project = var.project
  zone         = var.zone
  tags = [var.tag]
  boot_disk {
    initialize_params {
      image = var.boot_os
    }
  }
  network_interface {
    network = var.network

    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = data.template_file.chef_setup.rendered

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.head-chef.email
    scopes = ["cloud-platform"]
  }
}

data "template_file" "chef_setup" {
    template ="${file("${path.module}/chef_setup.sh")}"
    vars = {
        region = var.region
        zone = var.zone
        project = var.project
        machine_type  = var.machine_type
        network = var.network

    }
}