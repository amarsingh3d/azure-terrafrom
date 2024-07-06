resource "azurerm_resource_group" "rg" {
  for_each = var.vnet
  name     = each.value.resource_group_name
  location = each.value.location
  tags     = each.value.tags
}

resource "azurerm_virtual_network" "network" {
  for_each            = var.vnet
  name                = "${each.key}-vnet"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  address_space       = each.value.address_space
  tags                = each.value.tags

  subnet {
    name           = each.value.subnet1.name
    address_prefix = each.value.subnet1.address_prefix
  }

  dynamic "subnet" {
    for_each = each.value.subnet2 != null ? [each.value.subnet2] : []
    content {
      name           = subnet.value.name
      address_prefix = subnet.value.address_prefix
    }
  }

  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_virtual_network_peering" "dev-to-prod" {
  name                      = "dev-to-prod-peering"
  resource_group_name       = azurerm_resource_group.rg["dev"].name
  virtual_network_name      = azurerm_virtual_network.network["dev"].name
  remote_virtual_network_id = azurerm_virtual_network.network["prod"].id

}

resource "azurerm_virtual_network_peering" "prod-to-dev" {
  name                      = "prod-to-dev-peering"
  resource_group_name       = azurerm_resource_group.rg["prod"].name
  virtual_network_name      = azurerm_virtual_network.network["prod"].name
  remote_virtual_network_id = azurerm_virtual_network.network["dev"].id

}
