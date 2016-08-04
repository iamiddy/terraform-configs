variable "access_key" {}
variable "secret_key" {}

variable "ecs_amis"{
  description = "The AMI for each EC2 instance in the cluster"
  type = "map"
  default = {
    us-east-1 = "ami-55870742"
    us-west-2 = "ami-241bd844"
  }
}

variable "instance_type" {
  default = "t2.micro"
}
variable "region" {
  default = "us-east-1"
}

variable "instance_port" {
  default = "80"
}

variable "ecs_cluster_subnet_ids" {
  description = "A comma-separated list of subnets where the EC2 instances for the ECS cluster should be deployed"
}

variable "key_pair_name" {
  description = "The name of the Key Pair that can be used to SSH to each EC2 instance in the ECS cluster"
}

variable "vpc_id" {
  description = "The id of the VPC where the ECS cluster should run"
}

variable "elb_subnet_ids" {
  description = "A comma-separated list of subnets where the ELBs should be deployed"
}

variable "ecs_cluster_subnet_ids" {
  description = "A comma-separated list of subnets where the EC2 instances for the ECS cluster should be deployed"
}

variable "rails_frontend_image" {
  description = "The name of the Docker image to deploy for the Rails frontend (e.g. brikis98/rails-frontend)"
}

variable "rails_frontend_version" {
  description = "The version (i.e. tag) of the Docker container to deploy for the Rails frontend (e.g. latest, 12345)"
}

variable "rails_frontend_port" {
  description = "The port the Rails frontend Docker container listens on for HTTP requests (e.g. 3000)"
  default = 3000
}

variable "sinatra_backend_image" {
  description = "The name of the Docker image to deploy for the Sinatra backend (e.g. brikis98/sinatra-backend)"
}

variable "sinatra_backend_version" {
  description = "The version (i.e. tag) of the Docker container to deploy for the Sinatra backend (e.g. latest, 12345)"
}

variable "sinatra_backend_port" {
  description = "The port the Sinatra backend Docker container listens on for HTTP requests (e.g. 4567)"
  default = 4567
}

variable "key_pair_name" {
  description = "The name of the Key Pair that can be used to SSH to each EC2 instance in the ECS cluster"
}
