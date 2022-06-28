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

resource "yandex_mdb_clickhouse_cluster" "ch-homework" {
  name        = "ch-homework"
  environment = "PRODUCTION"
  network_id  = "${yandex_vpc_network.ch-network.id}"

  clickhouse {
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = 16
    }
  }

  zookeeper {
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = 10
    }
  }

  database {
    name = "otus_db"
  }

  user {
    name     = "otus"
    password = "otussharedcluster2022"
    permission {
      database_name = "otus_db"
    }
    settings {
      max_memory_usage_for_user               = 1000000000
      read_overflow_mode                      = "throw"
      output_format_json_quote_64bit_integers = true
    }
    quota {
      interval_duration = 3600000
      queries           = 10000
      errors            = 1000
    }
    quota {
      interval_duration = 79800000
      queries           = 50000
      errors            = 5000
    }
  }

  host {
    type       = "CLICKHOUSE"
    zone       = "ru-central1-a"
    subnet_id  = "${yandex_vpc_subnet.ch-subnet-1.id}"
    shard_name = "shard1"
  }

  host {
    type       = "CLICKHOUSE"
    zone       = "ru-central1-b"
    subnet_id  = "${yandex_vpc_subnet.ch-subnet-2.id}"
    shard_name = "shard1"
  }

  host {
    type       = "CLICKHOUSE"
    zone       = "ru-central1-b"
    subnet_id  = "${yandex_vpc_subnet.ch-subnet-3.id}"
    shard_name = "shard2"
  }


  shard_group {
    name        = "shard_group"
    description = "Cluster configuration that contains two shards"
    shard_names = [
      "shard1", "shard2"
    ]
  }

  cloud_storage {
    enabled = false
  }
}

resource "yandex_vpc_network" "ch-network" {}

resource "yandex_vpc_subnet" "ch-subnet-1" {
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.ch-network.id}"
  v4_cidr_blocks = ["10.1.0.0/24"]
}

resource "yandex_vpc_subnet" "ch-subnet-2" {
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.ch-network.id}"
  v4_cidr_blocks = ["10.2.0.0/24"]
}

resource "yandex_vpc_subnet" "ch-subnet-3" {
  zone           = "ru-central1-c"
  network_id     = "${yandex_vpc_network.ch-network.id}"
  v4_cidr_blocks = ["10.3.0.0/24"]
}
