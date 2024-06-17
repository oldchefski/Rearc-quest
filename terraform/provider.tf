terraform {
  backend "local" {}
  required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = "~>5.0"
    }
  }
}

provider "aws" {
  profile = "terraform"
  region  = "us-east-2"
}
