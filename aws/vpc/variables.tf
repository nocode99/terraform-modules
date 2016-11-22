variable "name" {
    description = "Name for stack"
}

variable "env" {
    description = "Environment e.g. master, mgmt, integration"
}

variable "cidr_block" {
    description = "/16 cidr block to be used for VPC"
}

variable "private_subnets" {
    type        = "map"
    description = "CSV of private subnet masks"
}

variable "public_subnets" {
    type        = "map"
    description = "CSV of public subnet masks"
}

variable "availability_zones" {
    type        = "list"
    description = "CSV of availability zones"
}
