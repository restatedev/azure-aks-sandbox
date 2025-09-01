# Azure AKS

Standard Azure sandbox that provisions the following:

- VPN
- AKS Cluster

## Usage

To use this in your BYOC app, please use the `azure-aks` runner type:

```toml
version = "v1"

[runner]
runner_type = "azure-aks"

[sandbox]
terraform_version = "1.11.3"

[sandbox.public_repo]
directory = "."
repo      = "nuonco/azure-aks-sandbox"
branch    = "main"
```

## Testing

This sandbox can be tested outside of `nuon` by following these steps:

1. Ensure you have an Azure account setup and `az` installed
1. [Create Service Principal Credentials](https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-terraform?tabs=bash#create-a-service-principal)
1. Create a `terraform.tfvars` with the correct variable inputs

## Requirements

| Name                                                               | Version   |
| ------------------------------------------------------------------ | --------- |
| <a name="requirement_azapi"></a> [azapi](#requirement_azapi)       | ~> 2.4.0  |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm) | ~> 4.34.0 |

## Providers

| Name                                                         | Version |
| ------------------------------------------------------------ | ------- |
| <a name="provider_azapi"></a> [azapi](#provider_azapi)       | 2.4.0   |
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | 4.34.0  |
| <a name="provider_random"></a> [random](#provider_random)    | 3.7.2   |

## Modules

| Name                                         | Source                | Version   |
| -------------------------------------------- | --------------------- | --------- |
| <a name="module_aks"></a> [aks](#module_aks) | Azure/aks/azurerm//v4 | ~> 10.1.0 |

## Resources

| Name                                                                                                                                   | Type        |
| -------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [azapi_resource.ssh_public_key](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource)                    | resource    |
| [azapi_resource_action.ssh_public_key_gen](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource_action)  | resource    |
| [azurerm_container_registry.acr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry)   | resource    |
| [azurerm_dns_zone.public](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone)                    | resource    |
| [azurerm_private_dns_zone.internal](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone)  | resource    |
| [random_pet.ssh_key_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet)                          | resource    |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config)      | data source |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group)         | data source |
| [azurerm_subnet.existing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet)                   | data source |
| [azurerm_virtual_network.existing](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name                                                                                          | Description                                                            | Type     | Default            | Required |
| --------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- | -------- | ------------------ | :------: |
| <a name="input_cluster_version"></a> [cluster_version](#input_cluster_version)                | The Kubernetes version to use for the AKS cluster.                     | `string` | `"1.33"`           |    no    |
| <a name="input_internal_root_domain"></a> [internal_root_domain](#input_internal_root_domain) | The internal root domain.                                              | `string` | n/a                |   yes    |
| <a name="input_location"></a> [location](#input_location)                                     | The location to launch the cluster in                                  | `string` | n/a                |   yes    |
| <a name="input_node_count"></a> [node_count](#input_node_count)                               | The minimum number of nodes in the managed node pool.                  | `number` | `2`                |    no    |
| <a name="input_nuon_id"></a> [nuon_id](#input_nuon_id)                                        | The nuon id for this install. Used for naming purposes.                | `string` | n/a                |   yes    |
| <a name="input_private_subnet_names"></a> [private_subnet_names](#input_private_subnet_names) | The subnets to deploy private resources into.                          | `string` | n/a                |   yes    |
| <a name="input_public_root_domain"></a> [public_root_domain](#input_public_root_domain)       | The public root domain.                                                | `string` | n/a                |   yes    |
| <a name="input_public_subnet_names"></a> [public_subnet_names](#input_public_subnet_names)    | The subnets to deploy public resources into.                           | `string` | n/a                |   yes    |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name)    | The resource group name where the existing Virtual Network is located. | `string` | n/a                |   yes    |
| <a name="input_vm_size"></a> [vm_size](#input_vm_size)                                        | The image size.                                                        | `string` | `"standard_d2_v4"` |    no    |
| <a name="input_vnet_name"></a> [vnet_name](#input_vnet_name)                                  | The name of the existing Virtual Network created by Bicep.             | `string` | n/a                |   yes    |

## Outputs

| Name                                                                             | Description                                                                                                                                                                         |
| -------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <a name="output_account"></a> [account](#output_account)                         | A map of Azure account attributes: location, subscription_id, client_id, resource_group_name.                                                                                       |
| <a name="output_acr"></a> [acr](#output_acr)                                     | A map of ACR attributes: id, login_server.                                                                                                                                          |
| <a name="output_cluster"></a> [cluster](#output_cluster)                         | A map of AKS cluster attributes: id, name, client_certificate, client_key, cluster_ca_certificate, cluster_fqdn, oidc_issuer_url, location, kube_config_raw, kube_admin_config_raw. |
| <a name="output_internal_domain"></a> [internal_domain](#output_internal_domain) | A map of internal domain attributes: nameservers, name, id.                                                                                                                         |
| <a name="output_public_domain"></a> [public_domain](#output_public_domain)       | A map of public domain attributes: nameservers, name, id.                                                                                                                           |
| <a name="output_vnet"></a> [vnet](#output_vnet)                                  | A map of vnet attributes: name, subnet_ids.                                                                                                                                         |
