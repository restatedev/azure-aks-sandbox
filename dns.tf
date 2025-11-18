resource "azurerm_dns_zone" "public" {
  name                = var.public_root_domain
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone" "internal" {
  name                = var.internal_root_domain
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_dns_caa_record" "caa" {
  name                = "@" # @ represents the root domain
  zone_name           = azurerm_dns_zone.public.name
  resource_group_name = azurerm_dns_zone.public.resource_group_name
  ttl                 = 300

  record {
    flags = 0
    tag   = "issue"
    value = "letsencrypt.org"
  }
}
