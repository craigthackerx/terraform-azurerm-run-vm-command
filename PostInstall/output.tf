output "vm_id" {
  value = data.azurerm_virtual_machine.azure_vm.id
}

output "vm_name" {
  value = data.azurerm_virtual_machine.azure_vm.id
}

output "linux_extension" {
  value = azurerm_virtual_machine_extension.linux_vm.id
}

output "windows_extension" {
  value = azurerm_virtual_machine_extension.windows_vm.id
}
