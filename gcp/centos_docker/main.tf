provider "google" {
credentials = "${file("centos_practice.json")}"
project     = "robotic-circle-359714"
region      = "northamerica-northeast2"
}
  resource "google_compute_instance" "centos_practice" {
  name         = "centos-vm"
  machine_type = "e2-micro"
  zone         = "northamerica-northeast2-a"
  tags         = ["ssh"]

  metadata = {
    ssh-key= ":${file("id_rsa.pub.txt")}"
  }
  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  network_interface {
    network = "default"

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}
resource "google_compute_firewall" "ssh_centos" {
  name = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = "default"
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}
resource "google_compute_firewall" "centospractice" {
  name    = "centospractice"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80","5000"]
  }
  source_ranges = ["0.0.0.0/0"]
}
// A variable for extracting the external IP address of the VM
output "Web-server-URL" {
 value = join("",["http://",google_compute_instance.centos_practice.network_interface.0.access_config.0.nat_ip,":5000"])
}