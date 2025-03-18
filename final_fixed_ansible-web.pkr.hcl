packer {
  required_plugins {
    amazon = {
      version = ">= 1.3"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "amazon-ebs" "ubuntu_2404" {
  ami_name = "${var.ami_name}-${timestamp()}"
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-noble-24.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "packer-ansible-nginx"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "ansible" {
    ansible_env_vars = ["ANSIBLE_HOST_KEY_CHECKING=False"]
    playbook_file    = "./ansible/playbook.yml"
    user             = var.ssh_username
  }
}

variable "ssh_username" {
  type    = string
}

variable "ami_name" {
  type    = string
}

variable "aws_region" {
  type    = string
}

source "amazon-ebs" "ubuntu_2204" {
  region           = var.ami_region
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-22.04-amd64-server-*"
      virtualization-type = "hvm"
      root-device-type    = "ebs"
    }
    owners      = ["099720109477"]
    most_recent = true
  }
  instance_type     = "t2.micro"
  ssh_username      = var.ssh_username
  ami_name = "${var.ami_name}-${timestamp()}"
}

build {
  sources = ["amazon-ebs.ubuntu_2404"]

  provisioner "ansible" {
    playbook_file = "playbook.yml"
  }
}
