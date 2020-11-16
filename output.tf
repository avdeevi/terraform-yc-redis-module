#output "instances" {
# value = local.instances
#}

output "redis_hosts" {
  value =  yandex_mdb_redis_cluster.redis.host
}
