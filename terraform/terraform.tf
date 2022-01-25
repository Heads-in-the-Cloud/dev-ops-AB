terraform {
  backend "s3" {
    bucket         = "utopia-ab"
    key            = "terraform.tfstate"
    region         = var.region
    encrypt        = true
  }
}
