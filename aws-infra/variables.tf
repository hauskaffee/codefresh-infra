variable "owner" {
  type        = string
  description = "Name of the owner of the resources"
}


variable "vpc_cidr" {
  type        = string
  default     = "192.168.0.0/16"
  description = "VPC CIDR for the Environment"
}
