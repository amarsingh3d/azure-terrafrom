locals {
  dev_subnet_ids  = flatten([for subnet in azurerm_virtual_network.network["dev"].subnet : subnet.id])
  prod_subnet_ids = flatten([for subnet in azurerm_virtual_network.network["prod"].subnet : subnet.id])
  network_interface_ids = {
    dev  = local.dev_subnet_ids
    prod = local.prod_subnet_ids
  }
}

resource "azurerm_public_ip" "public_ip" {
  for_each = merge(
    { for idx in range(var.vm_instances.dev.count) : "dev-${idx}" => {
        environment = "dev"
      }
    },
    { for idx in range(var.vm_instances.prod.count) : "prod-${idx}" => {
        environment = "prod"
      }
    }
  )

  name                = "${each.key}-pip"
  location            = var.vm_instances[each.value.environment].location
  resource_group_name = var.vm_instances[each.value.environment].resource_group_name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  for_each = merge(
    { for idx in range(var.vm_instances.dev.count) : "dev-${idx}" => {
      environment = "dev"
      subnet_id   = local.dev_subnet_ids[idx % length(local.dev_subnet_ids)]
      }
    },
    { for idx in range(var.vm_instances.prod.count) : "prod-${idx}" => {
      environment = "prod"
      subnet_id   = local.prod_subnet_ids[idx % length(local.prod_subnet_ids)]
      }
    }
  )

 
  name                = "${each.key}-nic"
  location            = var.vm_instances[each.value.environment].location
  resource_group_name = var.vm_instances[each.value.environment].resource_group_name

  ip_configuration {
    name                          = "${each.key}-ipconfig"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip[each.key].id
  }

  tags = var.vm_instances[each.value.environment].tags
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = merge(
    { for idx in range(var.vm_instances.dev.count) : "dev-${idx}" => {
      environment          = "dev"
      network_interface_id = azurerm_network_interface.nic["dev-${idx}"].id
      }
    },
    { for idx in range(var.vm_instances.prod.count) : "prod-${idx}" => {
      environment          = "prod"
      network_interface_id = azurerm_network_interface.nic["prod-${idx}"].id
      }
    }
  )

  name                  = "${each.key}-vm"
  location              = var.vm_instances[each.value.environment].location
  resource_group_name   = var.vm_instances[each.value.environment].resource_group_name
  size                  = var.vm_instances[each.value.environment].size
  admin_username        = var.vm_instances[each.value.environment].admin_username
  network_interface_ids = [each.value.network_interface_id]

  admin_ssh_key {
    username   = var.vm_instances[each.value.environment].admin_username
    public_key = var.vm_instances[each.value.environment].admin_ssh_key
  }

  os_disk {
    caching              = var.vm_instances[each.value.environment].os_disk.caching
    storage_account_type = var.vm_instances[each.value.environment].os_disk.storage_account_type
  }

  source_image_reference {
    publisher = var.vm_instances[each.value.environment].source_image_reference.publisher
    offer     = var.vm_instances[each.value.environment].source_image_reference.offer
    sku       = var.vm_instances[each.value.environment].source_image_reference.sku
    version   = var.vm_instances[each.value.environment].source_image_reference.version
  }

  tags = var.vm_instances[each.value.environment].tags
}