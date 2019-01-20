provider "aws" {
  version = ">= 1.17.0"
  region  = "${var.region}"
}

provider "random" {
  version = "= 2.0.0"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "1.14.0"
  name               = "test-vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.3.0/24", "10.0.4.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  name    = "test-sg-https"
  vpc_id  = "${module.vpc.vpc_id}"
}
module "elastic_beanstalk_application" {
  source      = ".//terraform-aws-elastic-beanstalk-application"
  namespace   = "eb-app"
   stage       = "test"
  name        = "go-hello-world"
  description = "Test elastic_beanstalk_application"
}

module "elastic_beanstalk_environment" {
  source = ".//terraform-aws-elastic-beanstalk-environment"
  namespace = "eb-env"
  stage     = "test"
  name      = "go-hello-world-test"
  zone_id   = "${var.zone_id}"
  app       = "${module.elastic_beanstalk_application.app_name}"

  instance_type           = "t2.micro"
  autoscale_min           = 2
  autoscale_max           = 2
  updating_min_in_service = 0
  updating_max_batch      = 1

  loadbalancer_type   = "application"
  vpc_id              = "${module.vpc.vpc_id}"
  public_subnets      = "${module.vpc.public_subnets}"
  private_subnets     = "${module.vpc.private_subnets}"
  security_groups     = ["${module.security_group.this_security_group_id}"]
  solution_stack_name = "64bit Amazon Linux 2018.03 v2.9.4 running Go 1.11.4"
  keypair             = "AWS_Instance"
  associate_public_ip_address = "true"

  env_vars = "${
      map(
        "APP_ENV", "test"
      )
    }"
}
