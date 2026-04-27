terraform {
  backend "s3" {
    bucket         = "sre-chaos-lab-state-131250744801"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
