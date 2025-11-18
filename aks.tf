module "aks" {
  source  = "jackkleeman/aks/azurerm"
  version = "11.0.1-nodeprovisioning"

  identity_type = "SystemAssigned"

  location                    = var.location
  prefix                      = var.nuon_id
  resource_group_name         = data.azurerm_resource_group.rg.name
  kubernetes_version          = var.cluster_version
  automatic_channel_upgrade   = "patch"
  agents_count                = 1
  agents_max_count            = 1
  agents_max_pods             = 100
  agents_min_count            = 1
  agents_pool_max_surge       = 1
  agents_pool_name            = "agents"
  temporary_name_for_rotation = "agentstemp"

  azure_policy_enabled         = true
  host_encryption_enabled      = false
  only_critical_addons_enabled = true

  key_vault_secrets_provider_enabled = true
  local_account_disabled             = true
  log_analytics_workspace_enabled    = false
  net_profile_dns_service_ip         = local.dns_service_ip
  net_profile_service_cidr           = local.service_cidr
  net_profile_pod_cidr               = local.pod_cidr
  network_plugin                     = "azure"
  network_plugin_mode                = "overlay"
  network_policy                     = "azure"
  oidc_issuer_enabled                = true
  private_cluster_enabled            = false
  role_based_access_control_enabled  = true
  rbac_aad_azure_rbac_enabled        = true
  rbac_aad_tenant_id                 = data.azurerm_client_config.current.tenant_id
  sku_tier                           = "Standard"
  vnet_subnet                        = { id = data.azurerm_subnet.existing.id }
  attached_acr_id_map = {
    "${azurerm_container_registry.acr.name}" = azurerm_container_registry.acr.id
  }
  workload_identity_enabled = true

  node_provisioning_profile = {
    mode               = "Auto"
    default_node_pools = "None"
  }

  tags = local.default_tags
}

// Azure needs to be able to manage network resources in this resource group
resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Network Contributor"
  principal_id         = module.aks.cluster_identity.principal_id
}
