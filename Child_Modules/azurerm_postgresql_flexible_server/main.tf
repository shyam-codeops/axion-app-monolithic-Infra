resource "azurerm_postgresql_flexible_server" "postgres" {

  for_each = var.postgresql_server

  name                          = each.value.name
  resource_group_name           = each.value.resource_group_name
  location                      = each.value.location
  version                       = "18"
  public_network_access_enabled = true
  administrator_login           = each.value.administrator_login
  administrator_password        = each.value.administrator_password
  zone                          = "1"

  storage_mb   = 32768
  storage_tier = "P4"

  sku_name = "B_Standard_B1ms"
}

resource "azurerm_postgresql_flexible_server_database" "database" {
  for_each = var.postgresql_server

  name      = each.value.database_name
  server_id = azurerm_postgresql_flexible_server.postgres[each.key].id
  collation = "en_US.utf8"
  charset   = "UTF8"
}

#   # prevent the possibility of accidental data loss
#   lifecycle {
#     prevent_destroy = true
#   }
# 
