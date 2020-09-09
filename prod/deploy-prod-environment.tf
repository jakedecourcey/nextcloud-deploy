provider "aws" {
    profile = "default"
    region  = "us-east-1"
}

data "aws_ami" "prod-image" {
    most_recent = true
    owners = ["self"]
    filter {
      name   = "name"
      values = ["${var.project_name}-prod-image"]
    }
}

data "aws_eip" "prod-ip" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-prod"]
  }
}

resource "aws_security_group" "default" {
    name            = "prod_web_server"
    
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }

      egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
}

resource "aws_instance" "prod-instance" {
    instance_type   = "t2.nano"
    ami             = data.aws_ami.prod-image.id
    vpc_security_group_ids = ["${aws_security_group.default.id}"]
    tags = {
        Name = "${var.project_name}-prod"
    }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.prod-instance.id
  allocation_id = data.aws_eip.prod-ip.id
}
