provider "aws" {
  region = "us-east-1"
}

# Terraform guardará el estado localmente por ahora para simplificar el lab
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
