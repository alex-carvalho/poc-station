variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "instance_type" {
  type    = string
  default = "c7g.2xlarge"
}

variable "volume_size" {
  type    = number
  default = 30
}

variable "tailscale_auth_key" {
  type      = string
  sensitive = true
}
