variable "aws_region" {}
variable "aws_profile" {}
variable "vpc_cidr" {}

variable "cidrs" {
  type = "map"
}

data "aws_availability_zones" "avaible" {}
variable "dom_name" {}
variable "fargate_cpu" {}
variable "fargate_memory" {}
variable "app_count" {}
variable "app_image" {}
variable "app_port" {}