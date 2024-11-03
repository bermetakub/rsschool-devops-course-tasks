terraform {
  backend "s3" {
    bucket = "bermeta.terraform.tfstate.bucket"
    key    = "dev1"
    region = "us-east-1"
  }
}