# Azure Key Vault

[![DEV - Deploy Azure Resource](https://github.com/ArtiomLK/azure-bicep-key-vault/actions/workflows/dev.orchestrator.yml/badge.svg?branch=main&event=push)](https://github.com/ArtiomLK/azure-bicep-key-vault/actions/workflows/dev.orchestrator.yml)

[Reference examples][1]

## Locally test Azure Bicep Modules

```bash
# Create an Azure Resource Group
az group create \
--name 'rg-azure-bicep-resource' \
--location 'eastus2' \
--tags project=bicephub env=dev

# Deploy Sample Modules
az deployment group create \
--resource-group 'rg-azure-bicep-resource' \
--mode Complete \
--template-file examples/examples.bicep
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

## Additional Resources

- Key Vault
- PE
- [MS | Docs | Integrate Key Vault with Azure Private Link][2]

[1]: ./examples/examples.bicep
[2]: https://learn.microsoft.com/en-us/azure/key-vault/general/private-link-service
