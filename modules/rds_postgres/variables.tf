variable "allocated_storage" {
  type    = number
  default = 100
}
variable "availability_zone" {
  type    = string
  default = "us-east-1c"
}
variable "identifier" {
  type = string
}
variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}
variable "final_snapshot_identifier" {
  type = string
}
variable "tags" {
  type = map
}
variable "environment" {
  type = string
}
