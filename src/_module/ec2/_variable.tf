variable "app_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "ssh_sg_id" {
  type = string
}

variable "instance_type" {
  type = string
}

# 環境ごとに参照先を変える
variable "ec2_key_file_path" {
  type = string
}