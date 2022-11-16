resource "azurerm_mssql_server" "sql-srv" {
  name                         = "webapp-sqlserver"
  resource_group_name          = var.rgpname
  location                     = var.azloc
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
}

resource "azurerm_mssql_database" "app-sqldb" {
  name           = "acctest-db-d"
  server_id      = azurerm_mssql_server.sql-srv.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"

  auto_pause_delay_in_minutes = 60
  max_size_gb                 = 32
  min_capacity                = 0.5
  read_replica_count          = 0
  read_scale                  = false
  sku_name                    = "GP_S_Gen5_2"
  zone_redundant              = false
  geo_backup_enabled          = false
  storage_account_type = "Local"
}

resource "azurerm_private_endpoint" "sql-pe" {
  name                = "sql-endpoint"
  location            = var.azloc
  resource_group_name = var.rgpname
  subnet_id           = var.be_subnetid

  private_service_connection {
    name                           = "sql-privateserviceconnection"
    private_connection_resource_id = azurerm_mssql_server.sql-srv.id
    subresource_names              = [ "sqlServer" ]
    is_manual_connection           = false
  }
  depends_on = [
    azurerm_mssql_database.app-sqldb,
    azurerm_mssql_server.sql-srv
  ]
}