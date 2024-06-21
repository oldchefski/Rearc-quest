variable "subnet_cidrs" {
  type    = list(string)
  description = "CIDR Ranges for each us-east-2 AZ"
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "secret_word_key" {
  type        = string
  description = "Injects an environment variable (SECRET_WORD) into the Docker container"
  default     = "SECRET_WORD"
}

variable "secret_word_value" {
  type        = string
  description = "Injects an environment variable (SECRET_WORD) into the Docker container"
  default     = "TwelveFactor"
}

variable "ssl_cert_arn" {
  type        = string
  description = "Loadbalancer SSL Certificate ARN"
  default     = "replace with cert arn"
}
