resource "aws_security_group" "sg-elb" {
  name = "WebServer AutoScalingGroup - ELB"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP connections from VPN server"
  }

  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outbound traffic"
  }

  tags {
    Name = "Web_Server_Security_Group - ELB - ASG"
    Owner = "jalzati@anomali.com"
    Department = "DevOps"
    Environment = "research"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "webserver_elb" {
  name = "WebServer-ASG-LB"
  security_groups = ["${aws_security_group.sg-elb.id}"]
  availability_zones = [
    "${data.aws_availability_zones.available_azs.names}"]

 listener {
    lb_port           = "${var.webserver_port}"
    lb_protocol       = "http"
    instance_port     = "${var.webserver_port}"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    interval = 20
    target = "HTTP:${var.webserver_port}/"
    timeout = 2
    unhealthy_threshold = 2
  }

  tags {
    Name = "Web Server-ELB-ASG"
    Owner = "jalzati@anomali.com"
    Department = "DevOps"
    Environment = "research"
  }
}