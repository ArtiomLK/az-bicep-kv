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

@allowed([
  'dissabled'
  'enabled'
])
@description('Enable public network access')
param kv_enable_public_access string = 'enabled'
// var kv_enable_public_access_var = kv_enable_public_access ? ''

// @description('Subnet ID to enable KeyVault private endpoints')
// param kv_network_access string

// @description('Subnet ID to enable KeyVault private endpoints')
// param snet_pe_id bool

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
    publicNetworkAccess: kv_enable_public_access
  }
  tags: tags
}

output id string = keyVault.id
