
variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "cosmosdb_account" {
  description = "Cosmos DB Account"
  type = map(object({
    offer_type                = string
    kind                      = string
    automatic_failover_enabled = bool
    geo_location = object({
      failover_priority = number
    })
    consistency_policy = object({
      consistency_level       = string
      max_interval_in_seconds = number
      max_staleness_prefix    = number
    })
    databases = list(object({
      name       = string
      throughput = optional(number)
      containers = list(object({
        name               = string
        partition_key_paths = list(string)
        throughput         = optional(number)
      }))
    }))
  }))
}

variable "resource_group" {
  description = "Azure Resource Group"
  type        = string
}

variable "location" {
  description = "Azure Region"
  type        = string
}
