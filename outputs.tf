output "elb_dns_name" {
  value = "${aws_elb.webserver_elb.dns_name}"
}

output "elb_azs" {
  value = "${aws_elb.webserver_elb.availability_zones}"
}

output "elb_EC2s" {
  value = "${aws_elb.webserver_elb.instances}"
}

output "elb_Subnets" {
  value = "${aws_elb.webserver_elb.subnets}"
}