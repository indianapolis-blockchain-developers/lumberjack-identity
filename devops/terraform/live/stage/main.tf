provider "aws" {
    region                  = "${var.aws_region}"
    shared_credentials_file = "~/.aws/credentials" 
    profile                 = "lumberjack"
}

resource "aws_vpc" "lumberjack_vpc" {
    cidr_block = "${var.VPCCIDR}"
    enable_dns_support   = true
    enable_dns_hostnames = true   
    tags = {
        Name = "Lumberjack VPC"
    }
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
    domain_name_servers = ["1.1.1.1", "8.8.8.8"]
    domain_name = "ec2.internal"   
}

resource "aws_vpc_dhcp_options_association" "dns_association" {
    vpc_id          = "${aws_vpc.lumberjack_vpc.id}"
    dhcp_options_id = "${aws_vpc_dhcp_options.dns_resolver.id}"
}



resource "aws_subnet" "public" {
    vpc_id  = "${aws_vpc.lumberjack_vpc.id}"
    cidr_block = "${var.PublicSubnetCIDR}"
    availability_zone = "us-east-1a"

    tags {
        Name = "Public Subnet"
    }
}

resource "aws_subnet" "private" {
    vpc_id = "${aws_vpc.lumberjack_vpc.id}"
    cidr_block = "${var.PrivateSubnetCIDR}"
    availability_zone = "us-east-1a"

    tags {
        Name = "Private Subnet"
    }
}


resource "aws_instance" "bastion" {
    ami                                 = "ami-02eac2c0129f6376b"
    key_name                            = "${aws_key_pair.bastion_key.key_name}"
    instance_type                       = "${var.InstanceType}"
    vpc_security_group_ids              = ["${aws_security_group.bastion-sg.name}"]
    private_ip                          = "10.0.128.5"
    associate_public_ip_address         = true
    subnet_id = "${aws_subnet.public.id}"
    tags {
        Name = "bastion"
    }
}

resource "aws_security_group" "bastion-sg" {
    name = "bastion-security-group"
    vpc_id = "${aws_vpc.lumberjack_vpc.id}"

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
}

output "bastion_public_ip" {
    value = "${aws_instance.bastion.public_ip}"
}