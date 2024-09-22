resource "azurerm_storage_account" "sa" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = local.region
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true
  sftp_enabled             = true

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

resource "azurerm_storage_container" "file" {
  name                  = "snowdatalake"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"

  depends_on = [azurerm_storage_account.sa]
}

resource "azurerm_eventhub_namespace" "evh" {
  name                = local.event_hub_namespace_name
  location            = local.region
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  capacity            = 1

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}