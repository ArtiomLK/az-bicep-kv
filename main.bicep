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
var pdnsz_kv_id_parsed = split(pdnsz_kv_id, '/')
var pdnsz_kv_res = {
  sub_id: pdnsz_kv_id_parsed[1]
  rg_n: pdnsz_kv_id_parsed[3]
  name: last(pdnsz_kv_id_parsed)
}

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
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    subnet: {
      id: snet_kv_pe_id
    }
  }
}

// resource zoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-08-01' = if (!empty(snet_kv_pe_id))  {
//   name: '${privateEndpoint.name}/default'
//   properties:{
//     privateDnsZoneConfigs: [
//       {
//         name: 'privatelink${environment().suffixes.keyvaultDns}'
//         properties:{
//           privateDnsZoneId: pdnsz_kv_id
//         }
//       }
//     ]
//   }
// }

// ------------------------------------------------------------------------------------------------
// Crete Keyvault PDNSZ A Record
// ------------------------------------------------------------------------------------------------

// '/subscriptions/5f96bde1-56b4-48b1-9ec1-ed3f21a70196/resourceGroups/alz-vwan-eastus/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net'


// resource pdnsz 'Microsoft.Network/dnsZones@2018-05-01' existing = {
//   name: pdnsz_kv_res.name
//   scope: resourceGroup(pdnsz_kv_res.rg_n)
// }

// resource ARecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
//   name: 'privatelink.vaultcore.azure.net/${kv_n}'
//   parent: pdnsz
//   properties: {
//     ttl: 3600
//     aRecords: [
//       {
//         ipv4Address: reference(Nics[index], '2018-05-01').ipConfigurations[0].properties.privateIPAddress
//       }
//     ]
//   }
// }

module ARecord 'modules/pdnsz/ARecord.bicep' = {
  name: 'ARecord${kv_n}'
  scope: resourceGroup(pdnsz_kv_res.sub_id, pdnsz_kv_res.rg_n)
  params: {
    pe_ip: privateEndpoint.properties.networkInterfaces[0].properties.ipConfigurations[0].properties.privateIPAddress
    pdnsz_n: pdnsz_kv_res.name
    kv_n: kv_n
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
