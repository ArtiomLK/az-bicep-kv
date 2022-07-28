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
module kvPubStandard '../main.bicep' = {
  name: 'kv-stand-pub'
  params: {
    location: location
    kv_enable_rbac: false
    kv_n: take('kv-stand-pub-${guid(subscription().id, resourceGroup().id, tags.env)}', 24)
    kv_sku: 'standard'
  }
}

module kvPubPrem'../main.bicep' = {
  name: 'kv-prem-pub'
  params: {
    location: location
    kv_enable_rbac: false
    kv_n: take('kv-prem-pub-${guid(subscription().id, resourceGroup().id, tags.env)}', 24)
    kv_sku: 'premium'
  }
}

module kvPubStandardRBAC '../main.bicep' = {
  name: 'kv-stand-pub-rbac'
  params: {
    location: location
    kv_enable_rbac: true
    kv_n: take('${take('kv-stand-pub-rbac-', 23)}${guid(subscription().id, resourceGroup().id, tags.env)}', 24)
    kv_sku: 'standard'
  }
}

module kvPubPremRBAC'../main.bicep' = {
  name: 'kv-prem-pub-rbac'
  params: {
    location: location
    kv_enable_rbac: true
    kv_n: take('${take('kv-prem-pub-rbac-', 23)}${guid(subscription().id, resourceGroup().id, tags.env)}', 24)
    kv_sku: 'premium'
  }
}

// private

module kvPrivStandard '../main.bicep' = {
  name: 'kv-stand-priv'
  params: {
    location: location
    kv_enable_rbac: false
    kv_n: take('kv-stand-priv-${guid(subscription().id, resourceGroup().id, tags.env)}', 24)
    kv_sku: 'standard'
    kv_enable_public_access: 'dissabled'
  }
}

module kvPrivPrem'../main.bicep' = {
  name: 'kv-prem-priv'
  params: {
    location: location
    kv_enable_rbac: false
    kv_n: take('kv-prem-priv-${guid(subscription().id, resourceGroup().id, tags.env)}', 24)
    kv_sku: 'premium'
    kv_enable_public_access: 'dissabled'
  }
}

module kvPrivStandardRBAC '../main.bicep' = {
  name: 'kv-stand-priv-rbac'
  params: {
    location: location
    kv_enable_rbac: true
    kv_n: take('${take('kv-stand-priv-rbac-', 23)}${guid(subscription().id, resourceGroup().id, tags.env)}', 24)
    kv_sku: 'standard'
    kv_enable_public_access: 'dissabled'
  }
}

module kvPrivPremRBAC'../main.bicep' = {
  name: 'kv-prem-priv-rbac'
  params: {
    location: location
    kv_enable_rbac: true
    kv_n: take('${take('kv-prem-priv-rbac-', 23)}${guid(subscription().id, resourceGroup().id, tags.env)}', 24)
    kv_sku: 'premium'
    kv_enable_public_access: 'dissabled'
  }
}
