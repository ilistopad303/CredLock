data "azurerm_resource_group" "credlock-team-rg" {
  name = "credlock-team-rg"
}

resource "azurerm_network_interface" "vm-nic" {
  for_each            = toset(var.vm_names)
  location            = var.location
  name                = "${each.key}-nic"
  resource_group_name = data.azurerm_resource_group.credlock-team-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

}

resource "azurerm_windows_virtual_machine" "vm" {
  for_each              = toset(var.vm_names)
  location              = var.location
  name                  = each.key
  network_interface_ids = [resource.azurerm_network_interface.vm-nic[each.key].id]
  resource_group_name   = data.azurerm_resource_group.credlock-team-rg.name
  admin_username        = "adminuser"
  admin_password        = "P@ssword1234!"
  size                  = "Standard_B1s"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}