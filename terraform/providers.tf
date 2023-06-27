terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.62.1"
    },
    random = {
      source = "hashicorp/random"
      version = "3.5.1"
    }
  }
}

provider "azurerm" {}

provider "random" {}