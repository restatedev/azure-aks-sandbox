// CSI secrets store should have read access to the key vault
// TODO: this may not be needed, we could give rbac permissions to tunnel and ingress?
resource "azurerm_role_assignment" "aks_key_vault_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.aks.key_vault_secrets_provider.secret_identity[0].object_id
}

// Needed for runner to create secrets
# resource "azurerm_role_assignment" "runner_key_vault_administrator" {
#   scope                = var.key_vault_id
#   role_definition_name = "Key Vault Secrets Officer"
#   principal_id         = data.azuread_service_principal.runner_vmss.object_id
# }
