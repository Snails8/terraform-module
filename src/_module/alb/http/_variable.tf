variable "app_name" {
  description = "Application Name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "alb_sg" {
  description = "HTTP access security group"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet ids."
  type        = list(string)
}


