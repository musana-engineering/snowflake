// STORAGE ACCOUNT
resource "azurerm_storage_account" "sa" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = local.region
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
  sftp_enabled             = true

  network_rules {

    default_action = "Deny"
    ip_rules       = local.firewall_whitelist

    virtual_network_subnet_ids = [data.azurerm_subnet.core.id, data.azurerm_subnet.management.id]

    private_link_access {
      endpoint_resource_id = "/subscriptions/${local.subscription_id}/resourcegroups/*/providers/Microsoft.EventGrid/systemTopics/*"
      endpoint_tenant_id   = local.tenant_id
    }
    private_link_access {
      endpoint_resource_id = "/subscriptions/${local.subscription_id}/resourcegroups/*/providers/Microsoft.EventGrid/topics/*"
      endpoint_tenant_id   = local.tenant_id
    }
    private_link_access {
      endpoint_resource_id = "/subscriptions/${local.subscription_id}/resourcegroups/*/providers/Microsoft.EventGrid/domains/*"
      endpoint_tenant_id   = local.tenant_id
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

resource "azurerm_storage_container" "blob" {
  name                  = "snowdatalake"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"

  depends_on = [azurerm_storage_account.sa]
}

// PRIVATE ENDPOINTS
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



