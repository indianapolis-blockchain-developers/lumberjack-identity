provider "aws" {
    region                  = "${var.aws_region}"
    shared_credentials_file = "~/.aws/credentials" 
    profile                 = "lumberjack"
}

# The main VPC contains all the resources
resource "aws_vpc" "lumberjack" {
    cidr_block = "${var.VPCCIDR}"
    enable_dns_support   = true
    enable_dns_hostnames = true   
    tags = {
        Name = "Lumberjack VPC"
        resource-group = "${var.resource_group}"
    }
}

# The subnets contain actual resources

resource "aws_subnet" "public" {
    vpc_id            = "${aws_vpc.lumberjack.id}"
    cidr_block        = "${var.PublicSubnetCIDR}"
    availability_zone = "${var.availability_zone}"

    tags {
        Name = "Public Subnet"
    }
}

# This private subnet contains a real resoruce, shielded from the internet
resource "aws_subnet" "private" {
    vpc_id            = "${aws_vpc.lumberjack.id}"
    cidr_block        = "${var.PrivateSubnetCIDR}"
    availability_zone = "${var.availability_zone}"

    tags {
        Name = "Private Subnet"
    }
}    

# The internet gateway connects the public subnet to the internet
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.lumberjack.id}"
  tags {
    "Environment" = "${var.environment_tag}"
    resource-group = "${var.resource_group}"
  }
}

# The route tables are what make a VPC public or private, and controls where traffic flows.
resource "aws_route_table" "web-public-rt" {
    vpc_id = "${aws_vpc.lumberjack.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.igw.id}"
    }

    tags {
        Name = "Public Route Table Subnet"
        Environment = "${var.environment_tag}"
        resource-group = "${var.resource_group}"
    }
}

# Assign the route table the public subnet
resource "aws_route_table_association" web-public-rt {
    subnet_id = "${aws_subnet.public.id}"
    route_table_id = "${aws_route_table.web-public-rt.id}"
}

# The DHCP options set overrides the AWS/EC2 options
resource "aws_vpc_dhcp_options" "dns_resolver" {
    domain_name_servers = ["1.1.1.1", "8.8.8.8"]
    domain_name = "ec2.internal"
    tags {
        Name = "ec2.internal"
        resource-group = "${var.resource_group}"
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