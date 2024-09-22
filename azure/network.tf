module "network" {
  source              = "../modules/vnet/"
  tags                = local.tags
  location            = local.region
  firewall_whitelist  = local.firewall_whitelist
  resource_group_name = azurerm_resource_group.rg.name

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

data "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  depends_on          = [module.network]
}

data "azurerm_private_dns_zone" "file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  depends_on          = [module.network]
}

data "azurerm_subnet" "core" {
  name                 = local.subnet_name
  virtual_network_name = local.vnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  depends_on           = [module.network]
}

resource "azurerm_private_endpoint" "blob" {
  name                = "sa${local.storage_account_name}blob"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "eastus2"
  subnet_id           = data.azurerm_subnet.core.id
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.blob.id]
  }
  private_service_connection {
    name                           = "sa${local.storage_account_name}blob"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  tags       = local.tags
  depends_on = [module.network]
}

resource "azurerm_private_endpoint" "file" {
  name                = "sa${local.storage_account_name}file"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "eastus2"
  subnet_id           = data.azurerm_subnet.core.id
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.blob.id]
  }
  private_service_connection {
    name                           = "sa${local.storage_account_name}file"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["file"]
  }

  tags       = local.tags
  depends_on = [module.network]
}

