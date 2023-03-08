targetScope = 'resourceGroup'
// ------------------------------------------------------------------------------------------------
// Deployment parameters
// ------------------------------------------------------------------------------------------------
// Sample tags parameters
param tags object = {
  project: 'bicephub'
  env: 'dev'
}

param location string = resourceGroup().location

param kv_n string = take('${take('kv-stand-pub-rbac-', 23)}${replace(guid(subscription().id, resourceGroup().id, tags.env), '-', '')}', 24)

// ------------------------------------------------------------------------------------------------
// Public KV
// ------------------------------------------------------------------------------------------------
module kvStandardPublicRBAC '../main.bicep' = {
  name: '${kv_n}-deployment'
  params: {
    location: location
    tags: tags
    kv_enable_rbac: true
    kv_n: kv_n
    kv_sku: 'standard'
  }
}
