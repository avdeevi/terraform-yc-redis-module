data "terraform_remote_state" "subnets" {
  backend = "s3"
  config = {
    endpoint                    = "storage.yandexcloud.net"
    bucket                      = "terraform-state-backet"
    region                      = "us-east-1"
    key                         = "${var.env}/network/terraform.tfstate"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

locals {

subnets = [ for z in range(var.shard_num):
            [ for  k,v in slice(data.terraform_remote_state.subnets.outputs["private_subnets"],0,var.replica_num):
              {
                zone = v.zone,
                id = v.id,
                shard = "shard${z + 1}"
              }
          ]
      ]
}

locals {
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

