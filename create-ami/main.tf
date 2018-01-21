variable "instance_id" {
  type = "string"
}

variable "aws_region" {
  type = "string"
}

variable "ami_name" {
  type = "string"
}

provider "aws" {
  region = "${var.aws_region}"
}

resource "null_resource" "delete_ami" {
  provisioner "local-exec" {
    when    = "destroy"
    command = "delete_ami.sh ${var.ami_name}"
  }
}

resource "aws_ami_from_instance" "parsec" {
  name               = "parsec-g2"
  source_instance_id = "${var.instance_id}"

  depends_on = ["null_resource.delete_ami"]
}