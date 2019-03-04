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
}

     
#     vpc_security_group_ids              = ["${aws_security_group.bastion-sg.id}"]
     
resource "aws_instance" "rke-node" {
  count = 2
  ami                    = "${lookup(var.amis, var.aws_region)}"
  instance_type          = "${var.InstanceType}"
  key_name               = "${aws_key_pair.rke-node-key.id}"
  # iam_instance_profile   = "${aws_iam_instance_profile.rke-aws.name}"
  vpc_security_group_ids = ["${aws_security_group.private_sg.id}"]
  subnet_id              = "${aws_subnet.private.id}"
  root_block_device {
      delete_on_termination = true
  }  
  tags {Name = "rke"}
}
