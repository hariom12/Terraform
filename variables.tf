variable "aws_region" {
  type        = "string"
  description = "The AWS Region"
  default     = "ap-southeast-2"
}
variable "aws_availability_zone" {
  type        = "string"
  description = "The default AWS availability zone"
  default     = "ap-southeast-2a"
}
variable "service_name" {
  type    = "string"
  default = "go-hello-world"
}
variable "service_description" {
  type    = "string"
  default = "My Test GO App"
}
