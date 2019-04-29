resource "aws_security_group" "sg-webserver" {
  name = "Web Server ASG"

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
    Name = "Web Server Security Group - ASG"
    Owner = "jalzati@anomali.com"
    Department = "DevOps"
    Environment = "research"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_key_pair" "webserver_keypair" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_launch_configuration" "webserver_launch_config" {
  image_id        = "${var.ami}"
  instance_type   = "${var.instance_type}"
  security_groups = ["${aws_security_group.sg-webserver.id}"]

  user_data = "${file("install_apache.sh")}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "webserver_asg" {
  launch_configuration = "${aws_launch_configuration.webserver_launch_config.id}"
  availability_zones = ["${data.aws_availability_zones.available_azs.names}"]

  min_size = 2
  max_size = 4

  tag {
    key = "Name"
    value = "WebServer ASG Example"
    propagate_at_launch = true
  }

  tag {
    key = "Owner"
    propagate_at_launch = false
    value = "${var.owner}"
  }

  tag {
    key = "Deparment"
    propagate_at_launch = false
    value = "${var.department}"
  }

  tag {
    key = "Environment"
    propagate_at_launch = false
    value = "${var.environment}"
  }
}