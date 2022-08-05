param kv_n string
param pdnsz_n string
param pe_ip string

resource pdnsz 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: pdnsz_n
}

resource ARecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: kv_n
  parent: pdnsz
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: pe_ip
      }
    ]
  }
}
