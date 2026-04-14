data "azurerm_resource_group" "credlock-team-rg" {
  name = "credlock-team-rg"
}

resource "azurerm_network_security_group" "main-security-group" {
  location            = var.location
  name                = "credlock-network-security-group"
  resource_group_name = data.azurerm_resource_group.credlock-team-rg.name
}

resource "azurerm_virtual_network" "credlock-vm-network" {
  location            = var.location
  name                = "credlock-vm-network"
  resource_group_name = data.azurerm_resource_group.credlock-team-rg.name
  address_space       = ["10.1.0.0/16"]
  subnet {
    name             = "internal_subnet"
    address_prefixes = ["10.1.1.0/24"]
    security_group   = azurerm_network_security_group.main-security-group.id
  }
}

data "azurerm_subnet" "subnet" {
  name                 = "internal_subnet"
  virtual_network_name = azurerm_virtual_network.credlock-vm-network.name
  resource_group_name  = data.azurerm_resource_group.credlock-team-rg.name
}

module "windows_vm" {
  source           = "./modules/vm"
  windows_vm_names = ["credlock-vm1", "credlock-vm2"]
  subnet_id        = data.azurerm_subnet.subnet.id
  location         = var.location
  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

# module "linux_vm" {
#   source         = "./modules/vm"
#   linux_vm_names = ["credlock-vm3", "credlock-vm4"]
#   subnet_id      = data.azurerm_subnet.subnet.id
#   location       = var.location
#   source_image_reference = {
#     publisher = "Canonical"
#     offer     = "ubuntu-22_04-lts"
#     sku       = "server"
#     version   = "latest"
#   }
# }

