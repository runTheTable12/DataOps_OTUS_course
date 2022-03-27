terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.yandex_cloud_token
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_cloud_folder_id
  zone      = "ru-central1-a"
}

resource "yandex_compute_instance" "otus-terraform-hw" {
  name = "otus-terraform-hw"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8k97s383n2e699qfbq"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-otus-terraform-hw.id
    nat       = true
  }
}

  resource "yandex_vpc_network" "network-otus-terraform-hw" {
  name = "network-otus-terraform-hw"
}

resource "yandex_vpc_subnet" "subnet-otus-terraform-hw" {
  name           = "subnet-otus-terraform-hw"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-otus-terraform-hw.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

output "internal_ip_address_otus-terraform-hw" {
  value = yandex_compute_instance.otus-terraform-hw.network_interface.0.ip_address
}

output "external_ip_address_otus-terraform-hw" {
  value = yandex_compute_instance.otus-terraform-hw.network_interface.0.nat_ip_address
}
