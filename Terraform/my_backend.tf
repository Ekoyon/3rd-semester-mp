terraform {
  backend "s3" {
    bucket = "assessmentb"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
