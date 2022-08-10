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

resource "yandex_vpc_network" "mlflow-hw-network" {
  name = "mlflow-hw-network"
}

resource "yandex_vpc_subnet" "subnet-mlflow-vm" {
  name           = "subnet-mlflow-vm"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.mlflow-hw-network.id
  v4_cidr_blocks = ["10.1.0.0/24"]
}

resource "yandex_vpc_subnet" "subnet-model-vm" {
  name           = "subnet-model-vm"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.mlflow-hw-network.id
  v4_cidr_blocks = ["10.2.0.0/24"]
}

resource "yandex_compute_instance" "mlflow-hw-vm" {
  name = "mlflow-hw-vm"

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = "fd81u2vhv3mc49l1ccbb"
      size = 50
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-mlflow-vm.id
    nat       = true
}
  metadata = {
    user-data = "${file("meta.txt")}"
}
  
}

resource "yandex_compute_instance" "model-hw-vm" {
  name = "model-hw-vm"

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = "fd81u2vhv3mc49l1ccbb"
      size = 50
    }
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-model-vm.id
    nat       = true
}
  metadata = {
    user-data = "${file("meta.txt")}"
}
  
}

output "internal_ip_address_mlflow_hw" {
  value = yandex_compute_instance.mlflow-hw-vm.network_interface.0.ip_address
}

output "external_ip_address_mlflow_hw" {
  value = yandex_compute_instance.mlflow-hw-vm.network_interface.0.nat_ip_address
}

output "internal_ip_address_model_hw" {
  value = yandex_compute_instance.model-hw-vm.network_interface.0.ip_address
}

output "external_ip_address_model_hw" {
  value = yandex_compute_instance.model-hw-vm.network_interface.0.nat_ip_address
}