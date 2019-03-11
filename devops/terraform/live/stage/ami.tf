resource "aws_instance" "bastion" {
    ami                                 = "${lookup(var.amis, var.aws_region)}"
    key_name                            = "${aws_key_pair.bastion_key.key_name}"
    instance_type                       = "${var.InstanceType}"
    vpc_security_group_ids              = ["${aws_security_group.bastion-sg.id}"]
    private_ip                          = "10.0.128.5"
    associate_public_ip_address         = true
    subnet_id = "${aws_subnet.public.id}"
    root_block_device {
        delete_on_termination = true
    }
    tags {
        Name = "bastion"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo yum -y update",
            "sudo yum -y install epel-release",
            "sudo yum -y install ansible",
            "sudo yum -y install python-boto",
            "sudo yum -y install vim",
            "mkdir inventory",
            "curl -O https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.py",
            "curl -O https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.ini",
            "mv ec2.* ~/inventory/",
            "chmod +x ~/inventory/ec2.py "
        ]     
    }

        connection {
            type = "ssh"
            user = "centos"
            private_key = "${file("~/.ssh/bastion_key.pem")}"
        }

}

     
#     vpc_security_group_ids              = ["${aws_security_group.bastion-sg.id}"]
     
resource "aws_instance" "rke-node" {
  count = 2
  ami                    = "${lookup(var.amis, var.aws_region)}"
  instance_type          = "${var.InstanceType}"
  key_name               = "${aws_key_pair.rke-node-key.id}"
  iam_instance_profile   = "${aws_iam_instance_profile.rke-aws.name}"
  vpc_security_group_ids = ["${aws_security_group.private_sg.id}"]
  subnet_id              = "${aws_subnet.private.id}"
  root_block_device {
      delete_on_termination = true
  }  
  tags {Name = "rke"}
}

