packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1.0"
    }
  }
}

variable "project_id" {
  type        = string
  description = "The GCP project ID where the image will be created."
  default = "user-mrcrgtmrczzs"
}

variable "zone" {
  type        = string
  description = "The GCP zone to launch the temporary instance in."
  default     = "us-central1-a"
}

variable "source_image_family" {
  type        = string
  description = "The source image family to use for the base image."
  default     = "debian-12"
}

variable "image_name" {
  type        = string
  description = "The name of the resulting GCP image."
  default     = "my-custom-debian-image-{{timestamp}}"
}

source "googlecompute" "my-gcp-image" {
  project_id          = var.project_id
  zone                = var.zone
  source_image_family = var.source_image_family
  image_name          = var.image_name
  image_family        = "my-custom-debian-image-family"         # the consistent family name
  ssh_username        = "packer" # Or the default user for your chosen source_image_family
  machine_type        = "e2-medium"
  disk_size           = 20
  disk_type           = "pd-standard"
  tags                = ["packer-build"]
}

build {
  name = "gcp-image-build"
  sources = ["source.googlecompute.my-gcp-image"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y apache2",
      "echo 'Hello from Packer on GCP! with apache2' | sudo tee /var/www/html/index.html",
      "sudo systemctl enable apache2",
      "sudo systemctl start apache2",
      "curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh",
      "sudo bash add-google-cloud-ops-agent-repo.sh --also-install",
      "sudo systemctl enable google-cloud-ops-agent",
      "sudo systemctl start google-cloud-ops-agent"
    ]
  }

//   # Example for copying files
//   provisioner "file" {
//     source      = "scripts/" # A local directory named 'scripts'
//     destination = "/tmp/scripts/"
//   }

//   provisioner "shell" {
//     execute_command = "chmod +x {{.Path}} && {{.Path}}"
//     scripts         = ["/tmp/scripts/setup.sh"] # An example script to run
//   }
}