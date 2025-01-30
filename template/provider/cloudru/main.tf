terraform {
  required_providers {
    sbercloud = {
      source  = "sbercloud-terraform/sbercloud"
      version = "1.12.0"
    }
  }
}

provider "sbercloud" {
  region = var.region
}
