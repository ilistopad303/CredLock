data "azurerm_resource_group" "credlock-team-rg" {
  name = "credlock-team-rg"
}

resource "azurerm_network_interface" "windows-vm-nic" {
  for_each            = toset(var.windows_vm_names)
  location            = var.location
  name                = "${each.key}-nic"
  resource_group_name = data.azurerm_resource_group.credlock-team-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "windows-vm" {
  for_each              = toset(var.windows_vm_names)
  location              = var.location
  name                  = each.key
  network_interface_ids = [resource.azurerm_network_interface.windows-vm-nic[each.key].id]
  resource_group_name   = data.azurerm_resource_group.credlock-team-rg.name
  admin_username        = "adminuser"
  admin_password        = "P@ssword1234!"
  size                  = "Standard_B2s"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
        publisher = var.source_image_reference.publisher
        offer     = var.source_image_reference.offer
        sku       = var.source_image_reference.sku
        version   = var.source_image_reference.version
  }
}

resource "azurerm_network_interface" "linux-vm-nic" {
  for_each            = toset(var.linux_vm_names)
  location            = var.location
  name                = "${each.key}-nic"
  resource_group_name = data.azurerm_resource_group.credlock-team-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_linux_virtual_machine" "linux-vm" {
  for_each = toset(var.linux_vm_names)
  location            = var.location
  name                = each.key
  resource_group_name = data.azurerm_resource_group.credlock-team-rg.name
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "P@ssword1234!"
  network_interface_ids = [resource.azurerm_network_interface.linux-vm-nic[each.key].id]
  disable_password_authentication = false
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }
}