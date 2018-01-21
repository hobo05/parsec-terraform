provider "aws" {
  region = "${var.aws_region}"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "parsec" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["${var.ami_name}"]
  }
}

data "aws_ebs_volume" "xvdb" {
  most_recent = true

  filter {
    name   = "attachment.instance-id"
    values = ["${aws_spot_instance_request.parsec.spot_instance_id}"]
  }

  filter {
    name   = "attachment.device"
    values = ["xvdb"]
  }

}

data "aws_subnet" "cheapest" {
  vpc_id            = "${data.aws_vpc.default.id}"
  availability_zone = "${var.aws_subnet_az}"
}

resource "aws_security_group" "parsec" {
  vpc_id      = "${data.aws_vpc.default.id}"
  name        = "parsec"
  description = "Allow inbound Parsec traffic and all outbound."

  ingress {
      from_port   = 8000
      to_port     = 8040
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = 5900
      to_port     = 5900
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = 5900
      to_port     = 5900
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_spot_instance_request" "parsec" {
    spot_price            = "${var.spot_price}"
    ami                   = "${data.aws_ami.parsec.id}"
    subnet_id             = "${data.aws_subnet.cheapest.id}"
    instance_type         = "${var.instance_type}"
    wait_for_fulfillment  = true

    tags {
        Name = "ParsecServer"
    }

    vpc_security_group_ids = ["${aws_security_group.parsec.id}"]
    associate_public_ip_address = true

    timeouts {
      delete = "60m"
    }

    provisioner "local-exec" {
      when    = "destroy"
      command = "cd create-ami && terraform plan -var 'ami_name=${var.ami_name}' -var 'aws_region=${var.aws_region}' -var 'instance_id=${aws_spot_instance_request.parsec.spot_instance_id}' -out=tfplan -input=false"
    }

    provisioner "local-exec" {
      when    = "destroy"
      command = "cd create-ami && terraform apply -input=false tfplan"
    }

    depends_on = ["null_resource.delete_volume"]
    depends_on = ["null_resource.delete_snapshot"]
}

resource "null_resource" "delete_volume" {
  provisioner "local-exec" {
    when    = "destroy"
    command = "aws ec2 delete-volume --volume-id ${data.aws_ebs_volume.xvdb.volume_id}"
  }
}

resource "null_resource" "delete_snapshot" {
  provisioner "local-exec" {
    when    = "destroy"
    command = "aws ec2 delete-snapshot --snapshot-id ${data.aws_ebs_volume.xvdb.snapshot_id}"
  }
}
