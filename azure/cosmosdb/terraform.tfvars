subscription_id = ""

resource_group = "rg-conquerplatform-dev-01"
location       = "eastus"

cosmosdb_account = {
  conquerproject-cosmosdb = {
    offer_type                = "Standard"
    kind                      = "GlobalDocumentDB"
    automatic_failover_enabled = true
    geo_location = {
      failover_priority = 0
    }
    consistency_policy = {
      consistency_level       = "BoundedStaleness"
      max_interval_in_seconds = 5
      max_staleness_prefix    = 100
    }
    databases = [
      {
        name       = "database1"
        throughput = 400
        containers = [
          {
            name               = "container1"
            partition_key_paths = ["/partitionKey"]
            throughput         = 400
          },
          {
            name               = "container2"
            partition_key_paths = ["/partitionKey"]
            throughput         = 400
          }
        ]
      },
      {
        name       = "database2"
        throughput = 400
        containers = [
          {
            name               = "container3"
            partition_key_paths = ["/partitionKey"]
            throughput         = 400
          },
          {
            name               = "container4"
            partition_key_paths = ["/partitionKey"]
            throughput         = 400
          }
        ]
      }
    ]
  }
}
