# locals {
#   azs = module.regions.regions_by_name[var.location].zones
# }

# module "regions" {
#   source  = "Azure/avm-utl-regions/azurerm"
#   version = "0.5.2"
#   # recommended_regions_only = false
# }
