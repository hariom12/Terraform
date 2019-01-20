variable "log_location_prefix" {
  default = "my-lb-logs"
}

variable "region" {
  default = "ap-southeast-2"
}

variable "log_bucket_name" {
  default = "test-log-bucket-go-hello-wolrd"
}
variable "zone_id" {
  default     = "Z22JAWXDAPN4R2"
  description = "Route53 parent zone ID. The module will create sub-domain DNS records in the parent zone for the EB environment"
}