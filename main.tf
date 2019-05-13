provider "aws" {
  region = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "anomali-alexa-terraform-state"
    key = "tf-upandrunning-01-asg-tfstate"
    region = "ca-central-1"
  }
}

