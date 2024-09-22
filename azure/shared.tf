locals {
  region                   = "eastus2"
  vnet_name                = "vnet-musana-eng"
  vnet_address_space       = ["10.141.0.0/16"]
  vnet_dns_servers         = ["168.63.129.16"]
  subnet_name              = "snet-core"
  subnet_address_space     = ["10.141.0.0/17"]
  storage_account_name     = "sasnowpoceus2"
  event_hub_namespace_name = "evhnsnowpoceus2"
  eventhub_name            = "evhsnowpoceus2"
  firewall_whitelist       = ["54.39.28.200", "54.39.137.255"]

  tags = {
    provisioner = "terraform"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "RG-SnowPOC"
  location = local.region
}


