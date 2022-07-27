targetScope = 'resourceGroup'
// ------------------------------------------------------------------------------------------------
// Deployment parameters
// ------------------------------------------------------------------------------------------------
param location string

@description('Az Resources tags')
param tags object = {}

// ------------------------------------------------------------------------------------------------
// KV Configuration parameters
// ------------------------------------------------------------------------------------------------
@description('Key Vault Name')
param kv_n string

@allowed([
  'standard'
  'premium'
])
@description('Key Vault SKU')
param kv_sku string

@description('Enable RBAC')
param kv_enable_rbac bool

// ------------------------------------------------------------------------------------------------
// Deploy KV
// ------------------------------------------------------------------------------------------------
resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' = {
  name: kv_n
  location: location
  properties: {
    enableRbacAuthorization: kv_enable_rbac
    sku: {
      name: kv_sku
      family: 'A'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
  }
  tags: tags
}

output id string = keyVault.id
