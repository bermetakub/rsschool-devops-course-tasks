terraform {
  backend "s3" {
    bucket = "terraform.tfstate.bucket "
    key    = "dev1"
    region = var.region
  }
}