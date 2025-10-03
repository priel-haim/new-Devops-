variable "project" { type = string default = "interview" }
variable "region" { type = string default = "eu-central-1" }
variable "vpc_cidr" { type = string default = "10.20.0.0/16" }
variable "public_subnets" { type = list(string) default = ["10.20.1.0/24"] }
variable "private_subnets" { type = list(string) default = ["10.20.2.0/24"] }


