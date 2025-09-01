locals {
  // app and services
  appgw_cidr     = "10.128.2.0/24"
  service_cidr   = "10.2.1.0/24"
  dns_service_ip = "10.2.1.10"
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
