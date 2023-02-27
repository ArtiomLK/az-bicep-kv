# Azure Key Vault

[![Deploy All Key Vault Examples](https://github.com/ArtiomLK/azure-bicep-key-vault/actions/workflows/dev.orchestrator.yml/badge.svg?branch=main&event=push)](https://github.com/ArtiomLK/azure-bicep-key-vault/actions/workflows/dev.orchestrator.yml)
[![Public Key Vault](https://github.com/ArtiomLK/azure-bicep-key-vault/actions/workflows/kv-public.yml/badge.svg?branch=main&event=push)](https://github.com/ArtiomLK/azure-bicep-key-vault/actions/workflows/kv-public.yml)
[![Private Key Vault](https://github.com/ArtiomLK/azure-bicep-key-vault/actions/workflows/kv-private.yml/badge.svg?branch=main&event=push)](https://github.com/ArtiomLK/azure-bicep-key-vault/actions/workflows/kv-private.yml)

[Reference examples][1]

## Locally test Azure Bicep Modules

```bash
sub_id="5f96bde1-56b4-48b1-9ec1-ed3f21a70196";        echo $sub_id
rg_n="rg-azure-bicep-key-vault-demo";                 echo $rg_n
l="eastus2";                                          echo $l
tags="env=dev project=bicephub";                      echo $tags

# Create an Azure Resource Group
az group create \
--subscription $sub_id \
--name $rg_n \
--location $l \
--tags $tags

# Deploy Examples
az deployment group create \
--subscription $sub_id \
--resource-group $rg_n \
--name "deployment-azure-bicep-key-vault" \
--mode Incremental \
--template-file examples/examples.bicep

# ------------------------------------------------------------------------------------------------
# Deploy Samples
# ------------------------------------------------------------------------------------------------
# Public kv
az deployment group create \
--subscription $sub_id \
--resource-group $rg_n \
--name "deployment-azure-bicep-key-vault-pub" \
--mode Incremental \
--template-file examples/kv-example.bicep

# Private kv - Default values
az deployment group create \
--subscription $sub_id \
--resource-group $rg_n \
--name "deployment-azure-bicep-key-vault-priv" \
--mode Incremental \
--template-file examples/kv-pe-example.bicep

# Private kv - Custom parameters
export MSYS_NO_PATHCONV=1
az deployment group create \
--subscription $sub_id \
--resource-group $rg_n \
--name "deployment-azure-bicep-key-vault-priv-custom" \
--mode Incremental \
--template-file examples/kv-pe-example.bicep \
--parameters \
  pdnsz_id="/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/<rg-name>/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net" \
  snet_id="/subscriptions/<xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx>/resourceGroups/<rg-name>/rg-name>/providers/Microsoft.Network/virtualNetworks/<vnet-name>/subnets/<snet-pe>"
```

## Locally Resolve PE

```bash
# modify hosts C:\Windows\System32\drivers\etc\hosts
# Add Private Endpoint IP with kv url
nnn.nnn.10.90        <kv_n>.vault.azure.net
```

## Delete and Purge KeyVaults

| :warning: | Delete all resources (mainly kv) nn the rg |
| --------- | :----------------------------------------- |

```bash
rg_n='rg-azure-bicep-key-vault';        echo $rg_n
l='eastus2';                            echo $rg_n

# avoids the C:/Program Files/Git/ being appended if required *
export MSYS_NO_PATHCONV=1

# Delete all resources (mainly kv) nn the rg
for id in `az resource list -g $rg_n --query "[].[id]" -o tsv`
do
  echo "deleting: ${id}";
  az resource delete --ids $id;
done

# Purge deleted keyVaults
for kv_n in `az keyvault list-deleted --query "[].[name]" -o tsv`
do
  echo "purging kv: ${kv_n}";
  echo $kv_n;
  # az keyvault purge --name $kv_n --location $l --no-wait;
  echo "";
done
```

## Monitoring Dashboards

- [Key Vault Insights][3]
  - KV -> Insights
  - Monitor -> Key Vaults

## Additional Resources

- Key Vault
- PE
- [MS | Docs | Integrate Key Vault with Azure Private Link][2]
- Monitoring
- [MS | Docs | Monitoring your key vault service with Key Vault insights][3]

[1]: ./examples/examples.bicep
[2]: https://learn.microsoft.com/en-us/azure/key-vault/general/private-link-service
[3]: https://learn.microsoft.com/en-us/azure/key-vault/key-vault-insights-overview
