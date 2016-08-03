variable "access_key" {}
variable "secret_key" {}
variable "amis"{
  type = "map"
  default = {
    us-east-1 = "ami-13be557e"
    us-west-2 = "ami-06b94666"
  }
}
variable "instance_type" {
  default = "t2.micro"
}
variable "region" {
  default = "us-east-1"
}