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
module kvStandardPublic '../main.bicep' = {
  name: 'stand-pub'
  params: {
    location: location
    kv_enable_rbac: false
    kv_n: take('${take('stand-pub-', 23)}${replace(guid(subscription().id, resourceGroup().id, tags.env), '-','')}', 24)
    kv_sku: 'standard'
  }
}

module kvPremiumPublic'../main.bicep' = {
  name: 'prem-pub'
  params: {
    location: location
    kv_enable_rbac: false
    kv_n: take('${take('prem-pub-', 23)}${replace(guid(subscription().id, resourceGroup().id, tags.env), '-', '')}', 24)
    kv_sku: 'premium'
  }
}

module kvStandardPublicRBAC '../main.bicep' = {
  name: 'stand-pub-rbac'
  params: {
    location: location
    kv_enable_rbac: true
    kv_n: take('${take('stand-pub-rbac-', 23)}${replace(guid(subscription().id, resourceGroup().id, tags.env), '-', '')}', 24)
    kv_sku: 'standard'
  }
}

module kvPremiumPublicRBAC'../main.bicep' = {
  name: 'prem-pub-rbac'
  params: {
    location: location
    kv_enable_rbac: true
    kv_n: take('${take('prem-pub-rbac-', 23)}${replace(guid(subscription().id, resourceGroup().id, tags.env), '-', '')}', 24)
    kv_sku: 'premium'
  }
}

// ------------------------------------------------------------------------------------------------
// Private Network Access
// ------------------------------------------------------------------------------------------------
module kvStandardPrivate '../main.bicep' = {
  name: 'stand-priv'
  params: {
    location: location
    kv_enable_rbac: false
    kv_n: take('${take('stand-priv-', 23)}${replace(guid(subscription().id, resourceGroup().id, tags.env), '-', '')}', 24)
    kv_sku: 'standard'
    kv_enable_public_access: 'disabled'
  }
}

module kvPremiumPrivate'../main.bicep' = {
  name: 'prem-priv'
  params: {
    location: location
    kv_enable_rbac: false
    kv_n: take('${take('prem-priv-', 23)}${replace(guid(subscription().id, resourceGroup().id, tags.env), '-', '')}', 24)
    kv_sku: 'premium'
    kv_enable_public_access: 'disabled'
  }
}

module kvStandardPrivateRBAC '../main.bicep' = {
  name: 'stand-priv-rbac'
  params: {
    location: location
    kv_enable_rbac: true
    kv_n: take('${take('stand-priv-rbac-', 23)}${replace(guid(subscription().id, resourceGroup().id, tags.env), '-', '')}', 24)
    kv_sku: 'standard'
    kv_enable_public_access: 'disabled'
  }
}

module kvPremiumPrivateRBAC'../main.bicep' = {
  name: 'prem-priv-rbac'
  params: {
    location: location
    kv_enable_rbac: true
    kv_n: take('${take('prem-priv-rbac-', 23)}${replace(guid(subscription().id, resourceGroup().id, tags.env), '-', '')}', 24)
    kv_sku: 'premium'
    kv_enable_public_access: 'disabled'
  }
}

// ------------------------------------------------------------------------------------------------
// Public Private Endpoint
// ------------------------------------------------------------------------------------------------
var subnets = [
  {
    name: 'snet-pe-azure-bicep-app-service'
    subnetPrefix: '192.160.0.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
    delegations: []
  }
]

resource vnetApp 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: 'vnet-azure-bicep-app-service'
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '192.160.0.0/23'
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

resource pdnsz 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink${environment().suffixes.keyvaultDns}'
  location: 'global'
  tags: tags
}

module kvStandardPublicPe '../main.bicep' = {
  name: 'stand-pub-pe'
  params: {
    location: location
    kv_enable_rbac: false
    kv_n: take('${take('stand-pub-pe-', 23)}${replace(guid(subscription().id, resourceGroup().id, tags.env), '-', '')}', 24)
    kv_sku: 'standard'
    snet_kv_pe_id: vnetApp.properties.subnets[0].id
    pdnsz_kv_id: pdnsz.id
  }
}

module kvPremiumPublicPe'../main.bicep' = {
  name: 'prem-pub-pe'
  params: {
    location: location
    kv_enable_rbac: false
    kv_n: take('${take('prem-pub-pe-', 23)}${replace(guid(subscription().id, resourceGroup().id, tags.env), '-', '')}', 24)
    kv_sku: 'premium'
    snet_kv_pe_id: vnetApp.properties.subnets[0].id
    pdnsz_kv_id: pdnsz.id
  }
}

module kvStandardPublicPeRBAC '../main.bicep' = {
  name: 'stand-pub-pe-rbac'
  params: {
    location: location
    kv_enable_rbac: true
    kv_n: take('${take('stand-pub-rbac-pe-', 23)}${replace(guid(subscription().id, resourceGroup().id, tags.env), '-', '')}', 24)
    kv_sku: 'standard'
    snet_kv_pe_id: vnetApp.properties.subnets[0].id
    pdnsz_kv_id: pdnsz.id
  }
}

module kvPremiumPublicPeRBAC'../main.bicep' = {
  name: 'prem-pub-pe-rbac'
  params: {
    location: location
    kv_enable_rbac: true
    kv_n: take('${take('prem-pub-pe-rbac-', 23)}${replace(guid(subscription().id, resourceGroup().id, tags.env), '-', '')}', 24)
    kv_sku: 'premium'
    snet_kv_pe_id: vnetApp.properties.subnets[0].id
    pdnsz_kv_id: pdnsz.id
  }
}

// ------------------------------------------------------------------------------------------------
// Private Private Endpoint
// ------------------------------------------------------------------------------------------------
module kvStandardPrivatePe '../main.bicep' = {
  name: 'stand-priv-pe'
  params: {
    location: location
    kv_enable_rbac: false
    kv_n: take('${take('stand-priv-pe-', 23)}${replace(guid(subscription().id, resourceGroup().id, tags.env), '-', '')}', 24)
    kv_sku: 'standard'
    kv_enable_public_access: 'disabled'
    snet_kv_pe_id: vnetApp.properties.subnets[0].id
    pdnsz_kv_id: pdnsz.id
  }
}

module kvPremiumPrivatePe'../main.bicep' = {
  name: 'prem-priv-pe'
  params: {
    location: location
    kv_enable_rbac: false
    kv_n: take('${take('prem-priv-pe-', 23)}${replace(guid(subscription().id, resourceGroup().id, tags.env), '-', '')}', 24)
    kv_sku: 'premium'
    kv_enable_public_access: 'disabled'
    snet_kv_pe_id: vnetApp.properties.subnets[0].id
    pdnsz_kv_id: pdnsz.id
  }
}

module kvStandardPrivatePeRBAC '../main.bicep' = {
  name: 'stand-priv-pe-rbac'
  params: {
    location: location
    kv_enable_rbac: true
    kv_n: take('${take('stand-priv-pe-rbac-', 23)}${replace(guid(subscription().id, resourceGroup().id, tags.env), '-', '')}', 24)
    kv_sku: 'standard'
    kv_enable_public_access: 'disabled'
    snet_kv_pe_id: vnetApp.properties.subnets[0].id
    pdnsz_kv_id: pdnsz.id
  }
}

module kvPremiumPrivatePeRBAC'../main.bicep' = {
  name: 'prem-priv-pe-rbac'
  params: {
    location: location
    kv_enable_rbac: true
    kv_n: take('${take('prem-priv-pe-rbac-', 23)}${replace(guid(subscription().id, resourceGroup().id, tags.env), '-', '')}', 24)
    kv_sku: 'premium'
    kv_enable_public_access: 'disabled'
    snet_kv_pe_id: vnetApp.properties.subnets[0].id
    pdnsz_kv_id: pdnsz.id
  }
}
