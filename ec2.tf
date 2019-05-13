resource "aws_security_group" "sg-webserver" {
  name = "Web Server ASG"

  ingress {
    from_port = "${var.webserver_port}"
    protocol = "tcp"
    to_port = "${var.webserver_port}"
    cidr_blocks = ["0.0.0.0/0"]
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
  key_name = "${var.key_name}"
  name = "WebServer ASG Example - Launch Config"

  user_data = "${file("install_apache.sh")}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "webserver_asg" {
  launch_configuration = "${aws_launch_configuration.webserver_launch_config.id}"
  availability_zones = ["${data.aws_availability_zones.available_azs.names}"]
  name = "WebServer ASG Example - AutoScaling Group"

  load_balancers = ["${aws_elb.webserver_elb.name}"]
  health_check_type = "ELB"

  min_size = 3
  max_size = 6

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

resource "aws_autoscaling_policy" "cpu-policy-scaleup" {
  name = "webserver-cpu-policy-scaleup"
  autoscaling_group_name = "${aws_autoscaling_group.webserver_asg.name}"
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = "1"
  cooldown = "300"
  policy_type = "SimpleScaling"
}

resource "aws_autoscaling_policy" "cpu-policy-scaledown" {
  name = "webserver-cpu-policy-scaledown"
  autoscaling_group_name = "${aws_autoscaling_group.webserver_asg.name}"
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = "-1"
  cooldown = "300"
  policy_type = "SimpleScaling"
}