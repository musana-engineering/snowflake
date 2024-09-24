resource "azurerm_eventhub_namespace" "evh" {
  name                = local.event_hub_namespace_name
  location            = local.region
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  capacity            = 1

  network_rulesets {
    trusted_service_access_enabled = true
    default_action                 = "Deny"

    virtual_network_rule {
      subnet_id = data.azurerm_subnet.core.id
    }

    ip_rule {
      ip_mask = "20.10.173.253"
      action  = "Allow"
    }
    ip_rule {
      ip_mask = "8.29.109.138"
      action  = "Allow"
    }
    ip_rule {
      ip_mask = "2a09:bac0:1001:fb::c:356"
      action  = "Allow"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

resource "azurerm_private_endpoint" "evh" {
  name                = local.event_hub_namespace_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = local.region
  subnet_id           = data.azurerm_subnet.core.id
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.eventhub.id]
  }
  private_service_connection {
    name                           = local.event_hub_namespace_name
    private_connection_resource_id = azurerm_eventhub_namespace.evh.id
    is_manual_connection           = false
    subresource_names              = ["namespace"]
  }

  tags       = local.tags
  depends_on = [module.network]
}

resource "azurerm_eventhub" "snowflake" {
  name                = "salesdata"
  namespace_name      = azurerm_eventhub_namespace.evh.name
  resource_group_name = azurerm_resource_group.rg.name
  partition_count     = 1
  message_retention   = 1
}

resource "azurerm_eventgrid_system_topic" "snowflake" {
  name                   = "salesdata"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = local.region
  source_arm_resource_id = azurerm_storage_account.sa.id
  topic_type             = "Microsoft.Storage.StorageAccounts"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "eventgrid-system-topic" {
  scope                = azurerm_eventhub_namespace.evh.id
  role_definition_name = "Azure Event Hubs Data Sender"
  principal_id         = azurerm_eventgrid_system_topic.snowflake.identity[0].principal_id
  depends_on           = [azurerm_eventhub_namespace.evh]
}

resource "azurerm_eventgrid_system_topic_event_subscription" "snowflake" {
  name                 = "BlobCreatedEvents"
  system_topic         = azurerm_eventgrid_system_topic.snowflake.name
  resource_group_name  = azurerm_resource_group.rg.name
  eventhub_endpoint_id = azurerm_eventhub.snowflake.id

  delivery_identity {
    type = "SystemAssigned"
  }
  depends_on = [azurerm_eventhub_namespace.evh,
  azurerm_eventhub.snowflake]
}