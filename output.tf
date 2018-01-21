output "aws_region" {
  value = "${var.aws_region}"
}

output "aws_subnet_az" {
  value = "${var.aws_subnet_az}"
}

output "aws_vpc" {
  value = "${var.aws_vpc}"
}

output "instance_type" {
  value = "${var.instance_type}"
}

output "spot_price" {
  value = "${var.spot_price}"
}

output "instance_id" {
  value = "${aws_spot_instance_request.parsec.spot_instance_id}"
}

output "ami_name" {
  value = "${var.ami_name}"
}