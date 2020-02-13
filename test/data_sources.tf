data "aws_availability_zones" "available" {}

data "aws_ami" "latestUbuntuBionic" {
  most_recent = true
  // ubuntu ami account ID
  owners = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
