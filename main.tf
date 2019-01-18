provider "aws" {
  region = "${var.aws_region}"
}

data "aws_availability_zones" "available" {}
data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket" "elb_logs" {
  bucket = "helloworld.com.logs"
  //acl    = "private"

  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::helloworld.com.logs/AWSLogs/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.main.arn}"
        ]
      }
    }
  ]
}
POLICY
}
resource "aws_vpc" "customvpc" {
  cidr_block = "10.0.0.0/16"
  tags {
        Name = "CustomVPC"
  }
}

resource "aws_internet_gateway" "customgateway" {
  vpc_id = "${aws_vpc.customvpc.id}"
}
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.customvpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.customgateway.id}"
}

resource "aws_subnet" "customsubnetprimary" {
  vpc_id                  = "${aws_vpc.customvpc.id}"
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags {
        Name = "Subnet A"
  }
}
resource "aws_subnet" "customsubnetsecondary" {
  vpc_id                  = "${aws_vpc.customvpc.id}"
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true

  tags {
        Name = "Subnet B"
  }
}


resource "aws_security_group" "customsecuritygroup" {
    vpc_id      = "${aws_vpc.customvpc.id}"
    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

}

resource "aws_lb" "customloadbalancer" {
  name               = "custom-lb-helloworld"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.customsecuritygroup.id}"]
  subnets            = ["${aws_subnet.customsubnetprimary.*.id}","${aws_subnet.customsubnetsecondary.*.id}"]

  enable_deletion_protection = true

  access_logs {
    bucket  = "${aws_s3_bucket.elb_logs.bucket}"
    //interval = 5
    //prefix  = "logs"
    //enabled = true
  }
  tags = {
    Name = "CustomloadBalancer"
  }
}

resource "aws_elastic_beanstalk_application" "eb_app" {
  name        = "${var.service_name}"
  description = "${var.service_description}"
}

module "app" {
  source      = ".//test"  
  aws_region = "${var.aws_region}"


  service_name        = "${var.service_name}"
  service_description = "${var.service_description}"
  APP_ENV             = "test"


  instance_type  = "t2.micro"
  min_instance   = "2"
  max_instance   = "2"


  enable_https           = "false"
  alb_connection_timeout = "120"

  vpc_id          = "${aws_vpc.customvpc.id}"
  vpc_subnets     = "${aws_subnet.customsubnetprimary.id}"
  alb_subnets     = "${aws_subnet.customsubnetsecondary.id}"
  security_groups = "${aws_security_group.customsecuritygroup.id}"
}
