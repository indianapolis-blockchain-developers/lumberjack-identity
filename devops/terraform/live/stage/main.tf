provider "aws" {
    region                  = "us-east-1"
    shared_credentials_file = "~/.aws/credentials" 
    profile                 = "lumberjack"
}

resource "aws_default_vpc" "default" {}

resource "aws_instance" "bastion" {
    ami                                 = "ami-02eac2c0129f6376b"
    key_name                            = "${aws_key_pair.bastion_key.key_name}"
    instance_type                       = "t2.micro"
    vpc_security_group_ids              = ["${aws_security_group.bastion-sg.name}"]
    associate_public_ip_address         = true
    tags {
        Name = "bastion"
    }
}

resource "aws_security_group" "bastion-sg" {
    name = "bastion-security-group"
    vpc_id = "${aws_default_vpc.default.id}"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
    }

    egress {
        protocol    = -1
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_key_pair" "bastion_key" {
    key_name   = "bastion_key.pem"
    public_key = ""
}

output "bastion_public_ip" {
    value = "${aws_instance.bastion.public_ip}"
}