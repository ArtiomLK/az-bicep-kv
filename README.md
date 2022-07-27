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

## Delete and Purge KeyVaults

```bash
# Delete all Resources in a resource group
rg_n='rg-azure-bicep-key-vault'; echo $rg_n

for res in `az resource list -g $rg_n`
do
  echo "res: $res";
  echo "";
done
# Delete KeyVaults

# Purge KeyVaults

az keyvault purge --name $kv_n --location $l --no-wait
```

[1]: ./examples/examples.bicep
