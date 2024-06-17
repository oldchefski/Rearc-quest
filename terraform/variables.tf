variable "subnet_cidrs" {
  type    = list(string)
  description = "CIDR Ranges for each us-east-2 AZ"
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
