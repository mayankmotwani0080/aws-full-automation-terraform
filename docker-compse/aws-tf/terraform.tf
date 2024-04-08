
#ssh key-pair
resource "aws_key_pair" "deployer" {
  key_name   = "aws_key_pair"
  public_key = file("${path.module}/id_rsa.pub")
}

#Security group
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
}

ingress {
  for_each = [443, 80, 27017]
  iterator = port
  content {
    security_group_id = aws_security_group.allow_tls.id
    cidr_ipv4         = aws_vpc.main.cidr_block
    from_port         = port.value
    ip_protocol       = "tcp"
    to_port           = port.value
  }
  

}
egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }


resource "aws_instance" "web" {
  ami           = "${var.image_id}"
  instance_type = "${var.instance_type}"
  security_group_id = ["${aws_security_group.allow_tls.id}"]
  key_name = "${aws_key_pair.aws_key_pair.key_name}"
  tags {
    Name = "first-tf-instance"
  }
}  