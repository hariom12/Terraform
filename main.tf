##################################################
## Your variables
##################################################
variable "aws_region" {
  type        = "string"
  description = "The AWS Region"
  default     = "ap-southeast-2"
}
variable "service_name" {
  type    = "string"
  default = "nodejs-app-test"
}
variable "service_description" {
  type    = "string"
  default = "My awesome nodeJs App"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

# Create a subnet for the ELB & EC2 intances
resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  availability_zone       = "${var.aws_region}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags {
        Name = "Subnet A"
  }
}
##################################################
## AWS config
##################################################
provider "aws" {
  region = "${var.aws_region}"
}

##################################################
## Elastic Beanstalk config
##################################################
resource "aws_elastic_beanstalk_application" "eb_app" {
  name        = "${var.service_name}"
  description = "${var.service_description}"
}

module "app" {
  source     = "github.com/hariom12/Terraform//eb-env"
  aws_region = "${var.aws_region}"

  # Application settings
  service_name        = "${var.service_name}"
  service_description = "${var.service_description}"
  env                 = "dev"

  # Instance settings
  instance_type  = "t2.micro"
  min_instance   = "2"
  max_instance   = "2"

  # ELB
  enable_https           = "false"
  elb_connection_timeout = "120"

  # Security
  vpc_id          = "${aws_vpc.default.id}"
  vpc_subnets     = "${aws_vpc.default.id}"
  elb_subnets     = "${aws_vpc.default.id}"
  security_groups = "sg-e1c3a998"
}

##################################################
## Route53 config
##################################################
#module "app_dns" {
#  source      = "github.com/hariom12/Terraform//r53-alias"
#  aws_region  = "${var.aws_region}"

#  domain      = "example.io"
#  domain_name = "app-test.example.io"
#  eb_cname    = "${module.app.eb_cname}"
#}
