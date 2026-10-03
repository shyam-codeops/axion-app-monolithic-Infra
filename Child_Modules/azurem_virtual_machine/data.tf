data "azurerm_network_interface" "nics" {
  for_each = var.vms
  name                = each.value.nic_name
  resource_group_name = each.value.resource_group_name
}

