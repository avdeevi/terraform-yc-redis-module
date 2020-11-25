data "yandex_resourcemanager_folder" "my_folder" {
  name =  var.env
}

data "yandex_vpc_subnet" "my_subnet_a" {
  name = "${var.env}-private-subnet${var.subnet_index}-a"
  folder_id = data.yandex_resourcemanager_folder.my_folder.id
}

data "yandex_vpc_subnet" "my_subnet_b" {
  name = "${var.env}-private-subnet${var.subnet_index}-b"
  folder_id = data.yandex_resourcemanager_folder.my_folder.id
}

data "yandex_vpc_subnet" "my_subnet_c" {
  name = "${var.env}-private-subnet${var.subnet_index}-c"
  folder_id = data.yandex_resourcemanager_folder.my_folder.id
}

locals {

list_subnets = [
        data.yandex_vpc_subnet.my_subnet_a,
        data.yandex_vpc_subnet.my_subnet_b,
        data.yandex_vpc_subnet.my_subnet_c
          ]

subnets = [ for z in range(var.shard_num):
            [ for  k,v in slice(local.list_subnets,0,var.replica_num):
              {
                zone = v.zone,
                id = v.id,
                shard = "shard${z + 1}"
              }
          ]
      ]

instances = flatten(local.subnets)
cluster_type = var.shard_num > 1 ? "sharded" : "standalone"

}


resource "yandex_mdb_redis_cluster" "redis" {
  name        = "${var.name}-${local.cluster_type}"
  environment = var.type
  network_id  = var.network_id
  sharded     = var.shard_num > 1 ? true : false
  folder_id   = var.folder_id

  config {
    password = var.redis_password
    version  = var.redis_version
 }

  resources {
    resource_preset_id = var.resource_preset
    disk_size          = var.disk_size
  }

  dynamic "host" {
    for_each = local.instances

    content {
      zone      = host.value.zone
      subnet_id = host.value.id
      shard_name = var.shard_num > 1 ? host.value.shard : ""
    }
  }
}

