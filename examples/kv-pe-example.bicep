targetScope = 'resourceGroup'
// ------------------------------------------------------------------------------------------------
// Deployment parameters
// ------------------------------------------------------------------------------------------------
var tags = {
  project: 'bicephub'
  env: 'dev'
}

param location string = resourceGroup().location

// ------------------------------------------------------------------------------------------------
// Deployment requirements
// ------------------------------------------------------------------------------------------------
// '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/<rg-name>/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net'
param pdnsz_id string = ''
// '/subscriptions/<xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx>/resourceGroups/<rg-name>/rg-name>/providers/Microsoft.Network/virtualNetworks/<vnet-name>/subnets/<snet-pe>'
param snet_id string = ''

resource pdnsz 'Microsoft.Network/privateDnsZones@2020-06-01' = if(empty(pdnsz_id)) {
  name: 'privatelink.vaultcore.azure.net'
  location: 'global'
  tags: tags
}

var subnets = [
  {
    name: 'snet-pe'
    subnetPrefix: '100.100.0.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
    delegations: []
  }
]

resource vnetApp 'Microsoft.Network/virtualNetworks@2021-02-01' = if(empty(snet_id)) {
  name: 'vnet-kv-bicep'
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '100.100.0.0/23'
      ]
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.subnetPrefix
        delegations: subnet.delegations
        privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
      }
    }]
  }
}

// ------------------------------------------------------------------------------------------------
// Private Private Endpoint
// ------------------------------------------------------------------------------------------------
module kvStandardPrivatePeRBAC '../main.bicep' = {
  name: 'kv-stand-priv-pe-rbac'
  params: {
    location: location
    tags: tags
    kv_enable_rbac: true
    kv_n: take('${take('kv-stand-priv-pe-rbac-', 23)}${replace(guid(subscription().id, resourceGroup().id, tags.env), '-', '')}', 24)
    kv_sku: 'standard'
    kv_enable_public_access: false
    snet_kv_pe_id: empty(snet_id) ? vnetApp.properties.subnets[0].id : snet_id
    pdnsz_kv_id: empty(pdnsz_id) ? pdnsz.id : pdnsz_id
  }
}
