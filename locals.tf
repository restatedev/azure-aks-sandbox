locals {
  private_subnet_name_list = split(",", var.private_subnet_names)
  public_subnet_name_list  = split(",", var.public_subnet_names)
}
