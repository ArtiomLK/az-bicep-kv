targetScope = 'resourceGroup'
// ------------------------------------------------------------------------------------------------
// Deployment parameters
// ------------------------------------------------------------------------------------------------
param tags object = {
  project: 'bicephub'
  env: 'dev'
}

param location string = resourceGroup().location

// ------------------------------------------------------------------------------------------------
// Deployment requirements
// ------------------------------------------------------------------------------------------------
param kv_n string = take('${take('kv-stand-priv-pe-rbac-', 23)}${replace(guid(subscription().id, resourceGroup().id, tags.env), '-', '')}', 24)
// '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/<rg-name>/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net'
param pdnsz_id string = ''
// '/subscriptions/<xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx>/resourceGroups/<rg-name>/rg-name>/providers/Microsoft.Network/virtualNetworks/<vnet-name>/subnets/<snet-pe>'
param snet_id string = ''
param vnet_n string = 'vnet-kv-ado-self-hosted-agents-${tags.env}-${location}'
param vnet_address string = '100.100.0.0/24'
param snet_pe_address string = '100.100.0.240/28'

resource pdnsz 'Microsoft.Network/privateDnsZones@2020-06-01' = if(empty(pdnsz_id)) {
  name: 'privatelink.vaultcore.azure.net'
  location: 'global'
  tags: tags
}

var subnets = [
  {
    name: 'snet-pe'
    subnetPrefix: snet_pe_address
    privateEndpointNetworkPolicies: 'Disabled'
    delegations: []
  }
]

resource vnetApp 'Microsoft.Network/virtualNetworks@2021-02-01' = if(empty(snet_id)) {
  name: vnet_n
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet_address
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
  name: '${kv_n}-deployment'
  params: {
    location: location
    tags: tags
    kv_enable_rbac: true
    kv_n: kv_n
    kv_sku: 'standard'
    kv_enable_public_access: false
    snet_kv_pe_id: empty(snet_id) ? vnetApp.properties.subnets[0].id : snet_id
    pdnsz_kv_id: empty(pdnsz_id) ? pdnsz.id : pdnsz_id
  }
}
