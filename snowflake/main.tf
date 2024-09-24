// TERRAFORM PROVIDER CONFIG
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.3.0"
    }
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.96.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "snowflake" {
  account  = var.account_name
  user     = var.account_username
  password = var.account_password
}

// LOCALS
locals {
  region          = "eastus2"
  tenant_id       = "de5b2627-b190-44c6-a3dc-11c4294198e1"
  subscription_id = "94476f39-40ea-4489-8831-da5475ccc163"
  tags = {
    provisioner = "terraform"
  }
}

