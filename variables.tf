variable "name" {
type = string
}
variable "type" {
type = string
}
variable "network_id" {
type = string
}
variable "folder_id"   {
type = string
}
variable "redis_version"   {
type = string
}
variable "resource_preset"   {
type = string
}
variable "disk_size"   {
type = number
}
variable "redis_password"   {
type = string
}
variable "env" {
type  = string
}
variable "replica_num" {
type = number
default = 0
}
variable "shard_num" {
 type = number
 default = 1
}

#variable "zone" {
#default = 0
#type = number
#}

#variable "sharded" {
# type = bool
#}
#
