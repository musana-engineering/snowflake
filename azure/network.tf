// DATA SOURCES
data "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = local.dns_zone_resource_group
}

data "azurerm_private_dns_zone" "file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = local.dns_zone_resource_group
}

data "azurerm_private_dns_zone" "eventhub" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = local.dns_zone_resource_group
}

data "azurerm_subnet" "core" {
  name                 = local.subnet_name
  virtual_network_name = local.vnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  depends_on           = [module.network]
}

data "azurerm_subnet" "management" {
  name                 = "snet-core"
  virtual_network_name = "vnet-core"
  resource_group_name  = local.dns_zone_resource_group
}

// VNET
module "network" {
  source               = "../modules/vnet/"
  tags                 = local.tags
  location             = local.region
  firewall_whitelist   = local.firewall_whitelist
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = local.vnet_name

  virtual_networks = {

    "core" = {
      name          = local.vnet_name
      address_space = local.vnet_address_space
      dns_servers   = local.vnet_dns_servers
    }
  }

  subnets = {

    "core" = {
      name                                          = local.subnet_name
      virtual_network_name                          = local.vnet_name
      address_prefixes                              = local.subnet_address_space
      private_endpoint_network_policies_enabled     = true
      private_link_service_network_policies_enabled = true
    }
  }
}



