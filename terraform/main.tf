data "azurerm_resource_group" "credlock-team-rg" {
  name = "credlock-team-rg"
}

resource "azurerm_network_security_group" "main-security-group" {
  location            = var.location
  name                = "credlock-network-security-group"
  resource_group_name = data.azurerm_resource_group.credlock-team-rg.name
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_network" "credlock-vm-network" {
  location            = var.location
  name                = "credlock-vm-network"
  resource_group_name = data.azurerm_resource_group.credlock-team-rg.name
  address_space       = ["10.1.0.0/16"]
  subnet {
    name           = "internal_subnet"
    address_prefixes = ["10.1.1.0/24"]
    security_group = azurerm_network_security_group.main-security-group.id
  }
}

data "azurerm_subnet" "subnet" {
  name                 = "internal_subnet"
  virtual_network_name = azurerm_virtual_network.credlock-vm-network.name
  resource_group_name  = data.azurerm_resource_group.credlock-team-rg.name
}


module "vm" {
  source    = "./modules/vm"
  vm_names  = ["credlock-vm1", "credlock-vm2"]
  subnet_id = data.azurerm_subnet.subnet.id
  location = var.location
}

