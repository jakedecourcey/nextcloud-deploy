provider "aws" {
    profile = "default"
    region  = "us-east-1"
}

data "aws_ami" "test-image" {
    most_recent = true
    owners = ["self"]
    filter {
      name   = "name"
      values = ["${var.project_name}-test-image"]
    }
}

resource "aws_security_group" "default" {
    name            = "test_web_server"
    
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

resource "aws_instance" "test-instance" {
    instance_type   = "t2.nano"
    ami             = data.aws_ami.test-image.id
    vpc_security_group_ids = ["${aws_security_group.default.id}"]
    tags = {
        Name = "${var.project_name}-test"
    }
}

output "instance_ip_addr" {
  value = aws_instance.test-instance.public_ip
}

