locals {
  settings_windows = {
    script   = compact(concat(tolist(var.command), split("\n", var.script)))
    fileUris = var.file_uris
  }

  settings_linux = {
    commandToExecute = var.command
    fileUris         = var.file_uris
    script           = base64encode(var.script)
  }
}

data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

data "azurerm_virtual_machine" "azure_vm" {
  name                = var.vm_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_virtual_machine_extension" "linux_vm" {
  count                      = lower(var.os_type) == "linux" ? 1 : 0
  name                       = "${var.vm_name}-run-command"
  publisher                  = "Microsoft.CPlat.Core"
  type                       = "RunCommandLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  protected_settings         = jsonencode(local.settings_linux)
  tags                       = var.tags
  virtual_machine_id         = data.azurerm_virtual_machine.azure_vm.id
}

resource "azurerm_virtual_machine_extension" "windows_vm" {
  count                      = lower(var.os_type) == "windows" ? 1 : 0
  name                       = "${var.vm_name}-run-command"
  publisher                  = "Microsoft.CPlat.Core"
  type                       = "RunCommandWindows"
  type_handler_version       = "1.1"
  auto_upgrade_minor_version = true
  settings                   = jsonencode(local.settings_windows)
  tags                       = var.tags
  virtual_machine_id         = data.azurerm_virtual_machine.azure_vm.id
}
