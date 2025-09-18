variable "region" {
  default = "us-east-2"
}

variable "s3_bucket_name" {
  default = "my-tts-website-terraform"
}

variable "alert_email" {
  description = "Email address for budget alerts"
  type        = string
  default     = "maryakussah123@gmail.com"
}
