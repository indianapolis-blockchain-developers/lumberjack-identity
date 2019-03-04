resource "aws_key_pair" "bastion_key" {
    key_name   = "bastion_key.pem"
    public_key = "${var.bastion_public_key}"
}

output "rke_private_key" {
  value = "${tls_private_key.node-key.private_key_pem}"
}

resource tls_private_key "node-key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "rke-node-key" {
  key_name   = "rke-node-key"
  public_key = "${tls_private_key.node-key.public_key_openssh}"
}