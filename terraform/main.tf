terraform {

  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }

  backend "s3" {
    key          = "terraform.tfstate"
    region       = "eu-west-2"
    use_lockfile = true
  }
}

provider "aws" {
  region = "eu-west-2"
}