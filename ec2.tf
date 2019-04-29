resource "aws_security_group" "sg-webserver" {
  name = "Web Server"
  vpc_id = "${aws_vpc.webserver_vpc.id}"

  ingress {
    from_port = "${var.webserver_port}"
    protocol = "tcp"
    to_port = "${var.webserver_port}"
    cidr_blocks = ["${var.vpn_ip}"]
    description = "Allow HTTP connections from anywhere in the Internet"
  }

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["${var.vpn_ip}"]
    description = "Allow SSH connections from only the VPN server"
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound traffic"
  }

  tags {
    Name = "Web Server Security Group"
    Owner = "jalzati@anomali.com"
    Department = "DevOps"
    Environment = "research"
  }
}

resource "aws_key_pair" "webserver_keypair" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}