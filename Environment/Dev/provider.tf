terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.72.0"
    }
  }
  # backend "azurerm" {
  #   resource_group_name  = "terraform-storage"
  #   storage_account_name = "terraformstorage011"
  #   container_name       = "tfstate"
  #   key                  = "terraform.devtfstate"
  # }
}

provider "azurerm" {
  features {}
}
