variable "aws_region" {
  type        = "string"
  description = "The AWS Region"
  default     = "ap-southeast-2a"
}
variable "service_name" {
  type    = "string"
  default = "go-app-test"
}
variable "service_description" {
  type    = "string"
  default = "My awesome GO App"
}
resource "aws_vpc" "customvpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "customgateway" {
  vpc_id = "${aws_vpc.customvpc.id}"
}
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.customvpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.customgateway.id}"
}

resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.customvpc.id}"
  availability_zone       = "${var.aws_region}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags {
        Name = "Subnet A"
  }
}

provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_elastic_beanstalk_application" "eb_app" {
  name        = "${var.service_name}"
  description = "${var.service_description}"
}

module "app" {
  source     = "github.com/hariom12/Terraform//eb-env"
  aws_region = "${var.aws_region}"


  service_name        = "${var.service_name}"
  service_description = "${var.service_description}"
  env                 = "dev"


  instance_type  = "t2.micro"
  min_instance   = "2"
  max_instance   = "2"


  enable_https           = "false"
  elb_connection_timeout = "120"

  vpc_id          = "${aws_vpc.customvpc.id}"
  vpc_subnets     = "${aws_vpc.customvpc.id}"
  elb_subnets     = "${aws_vpc.customvpc.id}"
  security_groups = "sg-e1c3a998"
}
