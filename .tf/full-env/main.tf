terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.99"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-central-1"
}

provider "random" {}
