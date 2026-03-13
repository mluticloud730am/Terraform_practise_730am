terraform {
  backend "s3" {
    bucket         = "terraform-state-rakesh"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}