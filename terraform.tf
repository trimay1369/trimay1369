# versions.tf
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# variables.tf
variable "gcp_project_id" {
  description = "The GCP project ID."
  type        = string
  default = "user-mrcrgtmrczzs"
}

variable "gcp_region" {
  description = "The GCP region to deploy resources in."
  type        = string
  default     = "us-central1"
}

data "google_compute_image" "latest_image" {
  project = var.gcp_project_id
  family  = "my-custom-debian-image-family"
}

# main.tf (or compute.tf, network.tf, etc.)
resource "google_compute_instance" "webserver" {
  name         = "webserver-instance"
  machine_type = "e2-medium"
  zone         = "${var.gcp_region}-a"
   tags         = ["webserver"]

  boot_disk {
    initialize_params {
    #   image = "debian-cloud/debian-11"
    # Reference the image self_link found by the data source
      image = data.google_compute_image.latest_image.self_link
    }
  }

  network_interface {
    network = "default" # Or your custom VPC network
    access_config {} # This assigns an ephemeral external IP
  }
}
resource "google_compute_firewall" "allow_http_default_network" {
  name    = "allow-http-ingress"
  network = "default" # Specifies the default network
  project = var.gcp_project_id # Replace with your GCP project ID

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["0.0.0.0/0"] # Allows traffic from any IP address

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags = ["webserver"] # Applies the rule to instances with this tag
  description = "Allow HTTP traffic on port 80 to instances with 'http-server' tag in the default network."
}