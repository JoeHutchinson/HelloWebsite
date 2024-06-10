terraform {
  #backend "s3" {}

  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }
  }
}

provider "aws" {
  region = var.region

  access_key = var.access_key
  secret_key = var.secret_key

  default_tags {
    tags = {
      team    = "payment-services"
      pci     = "out-of-scope"
      repo    = "github.com/JoeHutchinson/HelloWebsite"
      env     = var.env
    }
  }
}
