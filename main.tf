data "aws_ami" "ubuntu_arm" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "devops_sg" {
  name        = "devops-lab-sg"
  description = "Security group for DevOps lab instance"
  vpc_id      = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-sg"
  }
}

resource "aws_iam_role" "devops_role" {
  name = "devops-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attachment" {
  role       = aws_iam_role.devops_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "devops_profile" {
  name = "devops-ssm-profile"
  role = aws_iam_role.devops_role.name
}

resource "aws_instance" "devops_lab" {
  ami                    = data.aws_ami.ubuntu_arm.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.devops_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.devops_profile.name
  user_data              = templatefile("${path.module}/init.sh", {
    tailscale_auth_key = var.tailscale_auth_key
  })

  instance_market_options {
    market_type = "spot"
    spot_options {
      spot_instance_type             = "persistent"
      instance_interruption_behavior = "stop"
    }
  }

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = "gp3"
    delete_on_termination = false
  }

  tags = {
    Name = "devops-spot-lab"
  }
}
