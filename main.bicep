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
  'disabled'
  'enabled'
])
@description('Enable public network access')
param kv_enable_public_access string = 'enabled'

@description('subnet ID to Enable App Private Endpoints Connections')
param snet_kv_pe_id string = ''

// pdnszgroup - Add A records to PDNSZ for app pe
@description('Key Vault Private DNS Zone Resource ID where the A records will be written')
param pdnsz_kv_id string = ''

// ------------------------------------------------------------------------------------------------
// Enable KV PE
// ------------------------------------------------------------------------------------------------
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2020-06-01' = if (!empty(snet_kv_pe_id)) {
  name: 'pe-${kv_n}'
  location: location
  tags: tags
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'pe-${kv_n}-${take(guid(subscription().id, kv_n, resourceGroup().name), 4)}'
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
    subnet: {
      id: snet_kv_pe_id
    }
  }
}

resource zoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-08-01' = if (!empty(snet_kv_pe_id))  {
  name: '${privateEndpoint.name}/vault-PrivateDnsZoneGroup'
  properties:{
    privateDnsZoneConfigs: [
      {
        name: 'privatelink${environment().suffixes.keyvaultDns}'
        properties:{
          privateDnsZoneId: pdnsz_kv_id
        }
      }
    ]
  }
}

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
