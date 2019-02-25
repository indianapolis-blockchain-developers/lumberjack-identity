provider "aws" {
    region                  = "${var.aws_region}"
    shared_credentials_file = "~/.aws/credentials" 
    profile                 = "lumberjack"
}


resource "aws_vpc" "lumberjack" {
    cidr_block = "${var.VPCCIDR}"
    enable_dns_support   = true
    enable_dns_hostnames = true   
    tags = {
        Name = "Lumberjack VPC"
    }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.lumberjack.id}"
  tags {
    "Environment" = "${var.environment_tag}"
  }
}
resource "aws_vpc_dhcp_options" "dns_resolver" {
    domain_name_servers = ["1.1.1.1", "8.8.8.8"]
    domain_name = "ec2.internal"   
}

resource "aws_route_table" "rtb_public" {
    vpc_id = "${aws_vpc.lumberjack.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.igw.id}"
    }

    tags {
        "Environment" = "${var.environment_tag}"
    }
}

resource "aws_subnet" "public" {
    vpc_id            = "${aws_vpc.lumberjack.id}"
    cidr_block        = "${var.PublicSubnetCIDR}"
    availability_zone = "${var.availability_zone}"

    tags {
        Name = "Public Subnet"
    }
}

resource "aws_subnet" "private" {
    vpc_id            = "${aws_vpc.lumberjack.id}"
    cidr_block        = "${var.PrivateSubnetCIDR}"
    availability_zone = "${var.availability_zone}"

    tags {
        Name = "Private Subnet"
    }
}    

resource "aws_security_group" "bastion-sg" {
    vpc_id      = "${aws_vpc.lumberjack.id}"
    name        = "bastion-security-group"
    description = "AWS Security Group for Bastion Host"
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


resource "aws_instance" "bastion" {
    ami                                 = "${lookup(var.amis, var.aws_region)}"
    key_name                            = "${aws_key_pair.bastion_key.key_name}"
    instance_type                       = "${var.InstanceType}"
    vpc_security_group_ids              = ["${aws_security_group.bastion-sg.id}"]
    private_ip                          = "10.0.128.5"
    associate_public_ip_address         = true
    subnet_id = "${aws_subnet.public.id}"
    tags {
        Name = "bastion"
    }
}


resource "aws_key_pair" "bastion_key" {
    key_name   = "bastion_key.pem"
    public_key = "${var.bastion_public_key}"
}

output "bastion_public_ip" {
  value = "${aws_instance.bastion.public_ip}"
}