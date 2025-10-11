terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "soyspray-offsite-tfstate-syd"
    key            = "soyspray-offsite-backup/terraform.tfstate"
    use_lockfile   = true
    dynamodb_table = "terraform-state-lock-soyspray-offsite-syd"
    encrypt        = true
    region         = "ap-southeast-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
