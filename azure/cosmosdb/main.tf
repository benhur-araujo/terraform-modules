resource "azurerm_cosmosdb_account" "cosmosdb_account" {
  for_each = var.cosmosdb_account
  name                      = each.key
  location                  = var.location
  resource_group_name       = var.resource_group
  offer_type                = each.value.offer_type
  kind                      = each.value.kind
  automatic_failover_enabled = each.value.automatic_failover_enabled
 
  geo_location {
    location          = var.location
    failover_priority = each.value.geo_location.failover_priority
  }
  
  consistency_policy {
    consistency_level       = each.value.consistency_policy.consistency_level
    max_interval_in_seconds = each.value.consistency_policy.max_interval_in_seconds
    max_staleness_prefix    = each.value.consistency_policy.max_staleness_prefix
  }
}

locals {
  # Flatten the nested structure of databases within each cosmos account
  # This creates a list of maps, where each map represents a database
  databases = flatten([
    for account_key, account in var.cosmosdb_account : [
      for db in account.databases : {
        account_name = account_key
        name         = db.name
        throughput   = db.throughput
        containers   = db.containers
      }
    ]
  ])
}

# Create cosmos databases for each entry in the local.databases list
resource "azurerm_cosmosdb_sql_database" "database" {
  for_each            = { for db in local.databases : "${db.account_name}-${db.name}" => db }
  name                = each.value.name
  resource_group_name = var.resource_group
  account_name        = each.value.account_name
  throughput          = each.value.throughput

  depends_on = [
    azurerm_cosmosdb_account.cosmosdb_account
  ]
}

locals {
  # Flatten the nested structure of containers within each database
  # This creates a list of maps, where each map represents a container
  containers = flatten([
    for db in local.databases : [
      for container in db.containers : {
        account_name       = db.account_name
        database_name      = db.name
        container_name     = container.name
        partition_key_paths = container.partition_key_paths
        throughput         = container.throughput
      }
    ]
  ])
}

# Create cosmos containers for each entry in the local.containers list
resource "azurerm_cosmosdb_sql_container" "container" {
  for_each = { for container in local.containers : "${container.account_name}-${container.database_name}-${container.container_name}" => container }
  name                = each.value.container_name
  resource_group_name = var.resource_group
  account_name        = each.value.account_name
  database_name       = each.value.database_name
  partition_key_paths  = each.value.partition_key_paths
  throughput          = each.value.throughput
    
  depends_on = [
    azurerm_cosmosdb_sql_database.database
  ]
}
