# Azure Key Vault

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

[1]: ./examples/examples.bicep
