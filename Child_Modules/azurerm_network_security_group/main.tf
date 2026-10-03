resource "azurerm_network_security_group" "nsg" {
    for_each = var.network_security_group


  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"  #Traffic from any source
    destination_port_range     = each.value.destination_allow_port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface_security_group_association" "nsg-nic-association" {
    for_each = var.network_security_group
  network_interface_id      = data.azurerm_network_interface.nics[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}