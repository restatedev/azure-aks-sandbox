locals {
  service_cidr     = "10.2.1.0/24"
  dns_service_ip   = "10.2.1.10"
  pod_cidr         = "10.3.0.0/16"
  privatelink_cidr = "10.128.0.192/26"
}

// Data source to reference existing Virtual Network created by Bicep
data "azurerm_virtual_network" "existing" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

// Data source to reference existing subnet
data "azurerm_subnet" "existing" {
  name                 = local.private_subnet_name_list[0]
  virtual_network_name = data.azurerm_virtual_network.existing.name
  resource_group_name  = data.azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "privatelink" {
  name                 = "${var.nuon_id}-privatelink"
  virtual_network_name = data.azurerm_virtual_network.existing.name
  resource_group_name  = data.azurerm_resource_group.rg.name

  address_prefixes = [local.privatelink_cidr]

  private_link_service_network_policies_enabled = false
}
