terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "credlock-team-rg"
    storage_account_name = "credlockterraform"
    container_name       = "terraformstate"
    key                  = "terraformstatefile"
  }
}

provider "azurerm" {
  subscription_id = "e98e36a3-2842-4cc6-8286-2b44c456d59d"
  features {}
}
