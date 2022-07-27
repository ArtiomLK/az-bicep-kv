targetScope = 'resourceGroup'
// ------------------------------------------------------------------------------------------------
// Deployment parameters
// ------------------------------------------------------------------------------------------------
// Sample tags parameters
var tags = {
  project: 'bicephub'
  env: 'dev'
}

param location string = 'eastus2'

// ------------------------------------------------------------------------------------------------
// KeyVault Deployment Examples
// ------------------------------------------------------------------------------------------------
module kvpublicstandard '../main.bicep' = {
  name: 'kv-standard-public'
  params: {
    location: location
    kv_enable_rbac: true
    kv_n: take('kv-standard-public-${guid(subscription().id, resourceGroup().id, tags.env)}', 24)
    kv_sku: 'standard'
  }
}

module kvpublicpremium'../main.bicep' = {
  name: 'kv-premium-public'
  params: {
    location: location
    kv_enable_rbac: true
    kv_n: take('kv-premium-public-${guid(subscription().id, resourceGroup().id, tags.env)}', 24)
    kv_sku: 'premium'
  }
}
