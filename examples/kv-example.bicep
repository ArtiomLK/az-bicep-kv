targetScope = 'resourceGroup'
// ------------------------------------------------------------------------------------------------
// Deployment parameters
// ------------------------------------------------------------------------------------------------
// Sample tags parameters
var tags = {
  project: 'bicephub'
  env: 'dev'
}

param location string = resourceGroup().location

// ------------------------------------------------------------------------------------------------
// Public KV
// ------------------------------------------------------------------------------------------------
module kvStandardPublicRBAC '../main.bicep' = {
  name: 'kv-stand-pub-rbac'
  params: {
    location: location
    tags: tags
    kv_enable_rbac: true
    kv_n: take('${take('kv-stand-pub-rbac-', 23)}${replace(guid(subscription().id, resourceGroup().id, tags.env), '-', '')}', 24)
    kv_sku: 'standard'
  }
}
