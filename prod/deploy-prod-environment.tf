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
    values = ["${var.project_name}"]
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
        from_port   = 443
        to_port     = 443
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
    instance_type   = "t2.micro"
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

resource "aws_key_pair" "prod-keys" {
  key_name = "nextcloud-keys"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCus5+64KBreEk9PC8EvsqsfXuhH6cPq5sgJOfWm+Sse3Ow4w+xagsBZSoJsjRL5PsMW2Jn9DnEsAHtPO7e+ZB3vSVh1ECWp9E+4UA2mHaNqYDjJ16r9T84aCAbhRNFNx0YX0gIDt3vRJsCuwgHIZYsp1E82h6jSAimA1cC/I4Y7izCS9m4w5Q2IZ0sictCpaT/t/UpDwwIxPws+ixlmOaVQPyDNRbqjRWEz7/yft6Ene6GGugPj/vVJ/eAtVQcMUlVsniCUCXCS3aA+Fwh89DKiwE88tnEiankBHR9+geYD64Dn2G87VCKNisvZFELMryRmIit+J+WnWf5dzHJAttCJfCWoEc5qm1N14ns2qvYsXM9zaeTx/UMk8W49+4ogMasgW5RaO9kWJBusO3fNm6L9kKs5nZV5MCQb2JpBgwNUWgNq17LIXEX/I3yn5tynOc+jbWnyOyF4+pfbZm3DX2B9tyNfa3EFAuX+VLukQ2zysIOI3QV77Sl7z8pINgnZKk= jacob@in-amber-clad"
}
