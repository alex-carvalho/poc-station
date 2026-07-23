variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "c7g.2xlarge"
}

variable "volume_size" {
  type    = number
  default = 30
}
