resource "azurerm_network_watcher" "watcher" {
  for_each            = var.virtual_networks
  name                = "netw-${each.value.name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_network_security_group" "nsg" {
  for_each            = var.subnets
  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  lifecycle { ignore_changes = [tags] }

  depends_on = [azurerm_subnet.subnet, azurerm_virtual_network.vnet]
}

resource "azurerm_virtual_network" "vnet" {
  for_each            = var.virtual_networks
  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = each.value.address_space
  dns_servers         = each.value.dns_servers

  tags = var.tags
  lifecycle { ignore_changes = [tags] }
}

resource "azurerm_subnet" "subnet" {
  for_each                                      = var.subnets
  name                                          = each.value.name
  resource_group_name                           = var.resource_group_name
  virtual_network_name                          = each.value.virtual_network_name
  address_prefixes                              = each.value.address_prefixes
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.Sql",
    "Microsoft.ContainerRegistry",
    "Microsoft.AzureCosmosDB",
    "Microsoft.KeyVault",
    "Microsoft.ServiceBus",
    "Microsoft.EventHub",
    "Microsoft.AzureActiveDirectory",
  "Microsoft.Web"]

  lifecycle {
    ignore_changes = [private_link_service_network_policies_enabled, delegation]
  }

  depends_on = [azurerm_virtual_network.vnet]
}

resource "azurerm_subnet_network_security_group_association" "nsg" {
  for_each                  = var.subnets
  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id

  depends_on = [azurerm_subnet.subnet, azurerm_network_security_group.nsg]
}

resource "azurerm_private_dns_zone" "core" {
  for_each            = toset(var.private_dns_zones)
  name                = each.value
  resource_group_name = var.resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = "vnet-musana-eng"
  resource_group_name = var.resource_group_name

  depends_on = [azurerm_virtual_network.vnet]
}

data "azurerm_subnet" "aks" {
  name                 = "snet-core"
  virtual_network_name = "vnet-musana-eng"
  resource_group_name  = var.resource_group_name
  depends_on           = [azurerm_subnet.subnet, azurerm_virtual_network.vnet]
}

resource "azurerm_private_dns_zone_virtual_network_link" "core" {
  for_each              = toset(var.private_dns_zones)
  name                  = "vnet-musana-eng"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value
  virtual_network_id    = data.azurerm_virtual_network.vnet.id
  tags                  = var.tags
  depends_on = [azurerm_virtual_network.vnet,
  azurerm_private_dns_zone.core]
}

