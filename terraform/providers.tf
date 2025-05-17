terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.0.0-beta1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  shared_credentials_files = ["C:\\Users\\SANJANITH\\.aws\\credentials"]
  profile = "terraaform_practice"
}
