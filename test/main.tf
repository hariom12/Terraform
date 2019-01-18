provider "aws" {
  profile = "${var.aws_profile}"
  region = "${var.aws_region}"
}
resource "aws_iam_instance_profile" "beanstalk_service" {
  name = "${var.service_name}-${var.APP_ENV}-beanstalk-service-user"
  role = "${aws_iam_role.beanstalk_service.name}"
}
resource "aws_iam_instance_profile" "beanstalk_ec2" {
  name = "${var.service_name}-${var.APP_ENV}-beanstalk-ec2-user"
  role = "${aws_iam_role.beanstalk_ec2.name}"
}
resource "aws_iam_role" "beanstalk_service" {
  name = "${var.service_name}-${var.APP_ENV}-beanstalk-service-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticbeanstalk.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "elasticbeanstalk"
        }
      }
    }
  ]
}
EOF
}
resource "aws_iam_role" "beanstalk_ec2" {
  name = "${var.service_name}-${var.APP_ENV}-beanstalk-ec2-role"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_policy_attachment" "beanstalk_service" {
  name = "${var.service_name}-${var.APP_ENV}-elastic-beanstalk-service"
  roles = ["${aws_iam_role.beanstalk_service.id}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}
resource "aws_iam_policy_attachment" "beanstalk_service_health" {
  name = "${var.service_name}-${var.APP_ENV}-elastic-beanstalk-service-health"
  roles = ["${aws_iam_role.beanstalk_service.id}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}
resource "aws_iam_policy_attachment" "beanstalk_ec2_web" {
  name = "${var.service_name}-${var.APP_ENV}-elastic-beanstalk-ec2-web"
  roles = ["${aws_iam_role.beanstalk_ec2.id}"]
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}
resource "aws_elastic_beanstalk_environment" "eb_env" {
  name                = "${var.service_name}-${var.APP_ENV}"
  application         = "${var.service_name}"
  solution_stack_name = "${var.eb_solution_stack_name}"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "${var.instance_type}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "${var.ssh_key_name}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = "${var.security_groups}"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "${aws_iam_instance_profile.beanstalk_ec2.name}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = "${aws_iam_instance_profile.beanstalk_service.name}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${var.vpc_id}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${var.vpc_subnets}"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "${var.public_ip}"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "${var.min_instance}"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "${var.max_instance}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = "${var.deployment_policy}"
  }
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "IgnoreHealthCheck"
    value     = "${var.ignore_healthcheck}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }
  setting {
    namespace = "aws:elasticbeanstalk:application"
    name      = "Application Healthcheck URL"
    value     = "${var.healthcheck_url}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "APP_ENV"
    value     = "${var.APP_ENV}"
  }
   setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AWS_REGION"
    value     = "${var.aws_region}"
  }

}
