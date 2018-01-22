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

resource "aws_ami_from_instance" "parsec" {
  name               = "${var.ami_name}"
  source_instance_id = "${var.instance_id}"

  depends_on = ["null_resource.delete_ami"]
}
