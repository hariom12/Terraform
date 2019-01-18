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
variable "aws_availability_zone_2" {

}
variable "service_name" {
  type    = "string"
  default = "go-hello-world"
}
variable "service_description" {
  type    = "string"
  default = "My Test GO App"
}
variable "health_check_path" {
  type        = "string"
  default     = "/"
  description = "The destination for the health check request"
}

variable "health_check_timeout" {
  type        = "string"
  default     = "10"
  description = "The amount of time to wait in seconds before failing a health check request"
}

variable "health_check_healthy_threshold" {
  type        = "string"
  default     = "2"
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy"
}

variable "health_check_unhealthy_threshold" {
  type        = "string"
  default     = "2"
  description = "The number of consecutive health check failures required before considering the target unhealthy"
}

variable "health_check_interval" {
  type        = "string"
  default     = "15"
  description = "The duration in seconds in between health checks"
}

variable "health_check_matcher" {
  type        = "string"
  default     = "200-399"
  description = "The HTTP response codes to indicate a healthy check"
}

variable "deregistration_delay" {
  type        = "string"
  default     = "15"
  description = "The amount of time to wait in seconds before changing the state of a deregistering target to unused"
}
variable "http_enabled" {
  type        = "string"
  default     = "true"
  description = "A boolean flag to enable/disable HTTP listener"
}