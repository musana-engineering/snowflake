// TERRAFORM PROVIDER CONFIG
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

// LOCALS
locals {
  region                   = "eastus2"
  tenant_id                = "de5b2627-b190-44c6-a3dc-11c4294198e1"
  subscription_id          = "94476f39-40ea-4489-8831-da5475ccc163"
  vnet_name                = "vnet-javasips"
  vnet_address_space       = ["10.141.0.0/16"]
  vnet_dns_servers         = ["168.63.129.16"]
  subnet_name              = "snet-core"
  subnet_address_space     = ["10.141.0.0/17"]
  storage_account_name     = "sajavasips"
  event_hub_namespace_name = "evhn-javasips"
  resource_group_name      = "RG-JavaSips"
  dns_zone_resource_group  = "RG-Core"
  eventhub_name            = "evh-javasips"
  firewall_whitelist       = ["8.29.228.126", "8.29.109.138"]

  tags = {
    provisioner = "terraform"
  }
}

// RESOURCE GROUP
resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = local.region
}




