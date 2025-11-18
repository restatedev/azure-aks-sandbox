data "azurerm_client_config" "current" {}

data "azuread_service_principal" "runner_vmss" {
  display_name = "${var.nuon_id}-vmss"
}
