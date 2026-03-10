###Dev Variabled#####
variable "ami_id" {
description = "Passing values to ami_id"
default=""
type=string  
}

variable "instance_type" {
  description = "Passing values to instance_type"
default=""
type=string
}


###test Variabled#####
variable "test_ami_id" {
description = "Passing values to ami_id"
default=""
type=string  
}

variable "test_instance_type" {
  description = "Passing values to instance_type"
default=""
type=string
}