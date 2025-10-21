moved {
  from = module.windows_vm.azurerm_windows_virtual_machine.vm["credlock-vm2"]
  to   = module.windows_vm.azurerm_windows_virtual_machine.windows-vm["credlock-vm2"]
}
moved {
  from = module.windows_vm.azurerm_windows_virtual_machine.vm["credlock-vm1"]
  to   = module.windows_vm.azurerm_windows_virtual_machine.windows-vm["credlock-vm1"]
}
moved {
  from = module.windows_vm.azurerm_network_interface.vm-nic["credlock-vm2"]
  to   = module.windows_vm.azurerm_network_interface.windows-vm-nic["credlock-vm2"]
}
moved {
  from = module.windows_vm.azurerm_network_interface.vm-nic["credlock-vm1"]
  to   = module.windows_vm.azurerm_network_interface.windows-vm-nic["credlock-vm1"]
}
