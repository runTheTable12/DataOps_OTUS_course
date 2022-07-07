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

resource "yandex_vpc_network" "amundsen-hw-network" {
  name = "amundsen-hw-network"
}

resource "yandex_vpc_subnet" "subnet-amundsen-db" {
  name           = "subnet-amundsen-db"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.amundsen-hw-network.id
  v4_cidr_blocks = ["10.1.0.0/24"]
}

resource "yandex_vpc_subnet" "subnet-amundsen-vm" {
  name           = "subnet-amundsen-vm"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.amundsen-hw-network.id
  v4_cidr_blocks = ["10.2.0.0/24"]
}

resource "yandex_mdb_postgresql_cluster" "amundsen-hw-db" {
  name        = "amundsen-hw"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.amundsen-hw-network.id

  config {
    version = 12
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-hdd"
      disk_size          = 10
    }
    postgresql_config = {
      max_connections                   = 395
      enable_parallel_hash              = true
      vacuum_cleanup_index_scale_factor = 0.2
      autovacuum_vacuum_scale_factor    = 0.34
      default_transaction_isolation     = "TRANSACTION_ISOLATION_READ_COMMITTED"
      shared_preload_libraries          = "SHARED_PRELOAD_LIBRARIES_AUTO_EXPLAIN,SHARED_PRELOAD_LIBRARIES_PG_HINT_PLAN"
    }
  }

  maintenance_window {
    type = "WEEKLY"
    day  = "SAT"
    hour = 12
  }

  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.subnet-amundsen-db.id
  }
}

resource "yandex_mdb_postgresql_database" "homework-db" {
  cluster_id = yandex_mdb_postgresql_cluster.amundsen-hw-db.id
  name       = "homework-db"
  owner      = yandex_mdb_postgresql_user.anatolii.name
  lc_collate = "en_US.UTF-8"
  lc_type    = "en_US.UTF-8"
  extension {
    name = "uuid-ossp"
  }
  extension {
    name = "xml2"
  }
}

resource "yandex_mdb_postgresql_user" "anatolii" {
  cluster_id = yandex_mdb_postgresql_cluster.amundsen-hw-db.id
  name       = "anatolii"
  password   = "password"
}

resource "yandex_compute_instance" "amundsen-hw-vm" {
  name = "amundsen-hw-vm"

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
    subnet_id = yandex_vpc_subnet.subnet-amundsen-vm.id
    nat       = true
}
  metadata = {
    user-data = "${file("meta.txt")}"
}
  
}

output "internal_ip_address_otus-terraform-hw" {
  value = yandex_compute_instance.amundsen-hw-vm.network_interface.0.ip_address
}

output "external_ip_address_otus-terraform-hw" {
  value = yandex_compute_instance.amundsen-hw-vm.network_interface.0.nat_ip_address
}