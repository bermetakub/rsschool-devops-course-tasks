terraform {
  backend "s3" {
    bucket = "bermeta.terraform.tfstate.bucket"
    key    = "dev"
    region = "us-east-1"
  }
}