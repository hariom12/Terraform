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
  min_instance   = "1"
  max_instance   = "1"

  # ELB
  enable_https           = "false"
  elb_connection_timeout = "120"

  # Security
  vpc_id          = "vpc-227bf845"
  vpc_subnets     = "subnet-a72dd7ff"
  elb_subnets     = "subnet-59deaf10"
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
