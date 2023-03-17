# Azure Key Vault

[![Deploy All Key Vault Examples](https://github.com/ArtiomLK/azure-bicep-key-vault/actions/workflows/dev.orchestrator.yml/badge.svg?branch=main&event=push)](https://github.com/ArtiomLK/azure-bicep-key-vault/actions/workflows/dev.orchestrator.yml)
[![Public Key Vault](https://github.com/ArtiomLK/azure-bicep-key-vault/actions/workflows/kv-public.yml/badge.svg?branch=main&event=push)](https://github.com/ArtiomLK/azure-bicep-key-vault/actions/workflows/kv-public.yml)
[![Private Key Vault](https://github.com/ArtiomLK/azure-bicep-key-vault/actions/workflows/kv-private.yml/badge.svg?branch=main&event=push)](https://github.com/ArtiomLK/azure-bicep-key-vault/actions/workflows/kv-private.yml)

[Reference examples][1]

## Azure Key Vault Security

- Azure Key Vault Authentication
  - [MS | Docs | Authentication in Azure Key Vault][8]
  - [MS | Docs | Conditional access][11]
- Azure Key Vault Authorization
  - RBAC
    - [MS | Docs | Data Plane | Azure built-in roles for Key Vault data plane operations][5]
    - [MS | Docs | Management Plane | Key vault Contributor][6]
- Vault Access Policies
  - [MS | Docs | Assign a Key Vault access policy][7]
- Network Security
  - [MS | Docs | Configure Azure Key Vault firewalls and virtual networks][14]
  - [MS | Docs | TLS and HTTPS][15]
  - [MS | Docs | NSG][16]
- Backup and restore behavior
  - [MS | Docs | Backup and restore behavior][9]
  - [MS | Docs | Backup and recovery][12]
- Azure Policy Regulatory Compliance controls for Azure Key Vault
  - [MS | Docs | Azure Policy Regulatory Compliance controls for Azure Key Vault][10]
- Azure security baseline for Key Vault
  - [MS | Docs | Azure security baseline for Key Vault][13]

## Locally test Azure Bicep Modules

```bash
sub_id="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";        echo $sub_id
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

# Private kv - Custom parameters (pdnsz_id and snet_id)
export MSYS_NO_PATHCONV=1
az deployment group create \
--subscription $sub_id \
--resource-group $rg_n \
--name "deployment-azure-bicep-key-vault-priv-custom" \
--mode Incremental \
--template-file examples/kv-pe-example.bicep \
--parameters \
  pdnsz_id="/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/<rg-name>/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net" \
  snet_id="/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/<rg-name>/rg-name>/providers/Microsoft.Network/virtualNetworks/<vnet-name>/subnets/<snet-pe>"

# Private kv - Custom parameters (kv_n, vnet and pdnsz_id)
export MSYS_NO_PATHCONV=1

az deployment group create \
--subscription $sub_id \
--resource-group $rg_n \
--name "deployment-azure-bicep-key-vault-priv-custom" \
--mode Incremental \
--template-file examples/kv-pe-example.bicep \
--parameters \
  kv_n="kv-ado-dev-eastus2" \
  vnet_n="vnet-kv-ado-self-hosted-agents-dev-eastus2" \
  vnet_address="100.100.0.0/24" \
  snet_pe_address="100.100.0.240/28" \
  pdnsz_id="/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-alz-pdnsz/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
```

## Allow user to create secrets IF using RBAC

```bash
kv_n="kv-name";                                  echo $kv_n

# get user name
USER_N=$(az account show --query "user.name" -o tsv); echo $USER_N
# Get kv resource id
KV_ID=$(az keyvault show --name $kv_n --query "id" -o tsv); echo $KV_ID

# https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#key-vault-administrator
az role assignment create \
--assignee $USER_N \
--role "Key Vault Administrator" \
--scope $KV_ID

# ------------------------------------------------------------------------------------------------
# Secrets
# ------------------------------------------------------------------------------------------------
# https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#key-vault-secrets-officer
az role assignment create \
--assignee $USER_N \
--role "Key Vault Secrets Officer" \
--scope $KV_ID

# https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#key-vault-secrets-user
az role assignment create \
--assignee $USER_N \
--role "Key Vault Secrets User" \
--scope $KV_ID

# ------------------------------------------------------------------------------------------------
# Certificates
# ------------------------------------------------------------------------------------------------
# https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#key-vault-certificates-officer
az role assignment create \
--assignee $USER_N \
--role "Key Vault Certificates Officer" \
--scope $KV_ID

# https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#key-vault-reader
az role assignment create \
--assignee $USER_N \
--role "Key Vault Reader" \
--scope $KV_ID

# ------------------------------------------------------------------------------------------------
# Keys
# ------------------------------------------------------------------------------------------------
# https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#key-vault-crypto-officer
az role assignment create \
--assignee $USER_N \
--role "Key Vault Crypto Officer" \
--scope $KV_ID

# https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#key-vault-crypto-user
az role assignment create \
--assignee $USER_N \
--role "Key Vault Crypto User" \
--scope $KV_ID

# ---
# add sample secret to the KV
# ---
az keyvault secret set --vault-name $kv_n --name "kv-secret-1" --value "kv-secret-1-value"
az keyvault secret set --vault-name $kv_n --name "kv-secret-2" --value "kv-secret-2-value"
az keyvault certificate create --vault-name $kv_n --name "MyCert" --policy "$(az keyvault certificate get-default-policy)"
az keyvault key create --vault-name $kv_n --name "MyKey" --protection software

# retrieve secrets from KV
az keyvault secret show --vault-name $kv_n --name "kv-secret-1" --query "value"
az keyvault secret show --vault-name $kv_n --name "kv-secret-2" --query "value"
az keyvault certificate show --vault-name $kv_n --name "MyCert" --query "cer"
az keyvault key show --vault-name $kv_n --name "MyKey" --query "key.n"
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
- [MS | Docs | Authentication in Azure Key Vault][8]
- [MS | Docs | Azure built-in roles for Key Vault data plane operations][5]
- [MS | Docs | Management Plane | Key vault Contributor][6]
- [MS | Docs | Assign a Key Vault access policy][7]
- [MS | Docs | Best practices for using Azure Key Vault][4]
- PE
- [MS | Docs | Integrate Key Vault with Azure Private Link][2]
- Monitoring
- [MS | Docs | Monitoring your key vault service with Key Vault insights][3]

[1]: ./examples/examples.bicep
[2]: https://learn.microsoft.com/en-us/azure/key-vault/general/private-link-service
[3]: https://learn.microsoft.com/en-us/azure/key-vault/key-vault-insights-overview
[4]: https://learn.microsoft.com/en-us/azure/key-vault/general/best-practices
[5]: https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli#azure-built-in-roles-for-key-vault-data-plane-operations
[6]: https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#key-vault-contributor
[7]: https://learn.microsoft.com/en-us/azure/key-vault/general/assign-access-policy
[8]: https://learn.microsoft.com/en-us/azure/key-vault/general/authentication
[9]: https://learn.microsoft.com/en-us/azure/key-vault/general/overview-security-worlds#backup-and-restore-behavior
[10]: https://learn.microsoft.com/en-us/azure/key-vault/security-controls-policy
[11]: https://learn.microsoft.com/en-us/azure/key-vault/general/security-features#conditional-access
[12]: https://learn.microsoft.com/en-us/azure/key-vault/general/security-features#backup-and-recovery
[13]: https://learn.microsoft.com/en-us/security/benchmark/azure/baselines/key-vault-security-baseline
[14]: https://learn.microsoft.com/en-us/azure/key-vault/general/network-security
[15]: https://learn.microsoft.com/en-us/azure/key-vault/general/security-features#tls-and-https
[16]: https://learn.microsoft.com/en-us/security/benchmark/azure/baselines/key-vault-security-baseline#network-security-group-support
