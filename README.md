### Kudos to [innovationnorway](https://github.com/innovationnorway) - original makers of this module.
### Forked on 22/03/2021 - Converted to Terraform 0.14x format with AzureRM 2.48.1 Provider by [craigthackerx](https://github.com/craigthackerx) - [Terraform Registry](https://registry.terraform.io/modules/craigthackerx/run-vm-command/azurerm/latest)

# Run Commmand in Azure VM

Uses the VM agent to run PowerShell scripts (Windows) or shell scripts (Linux) within an Azure VM. It can be used to bootstrap/install software or run administrative tasks.

## Example Usage

### Install cURL (Linux)

```hcl
module "run_command" {
  source   = "./PostInstall"
  location = "US East"
  rg_name  = "myResourceGroup"
  vm_name  =  "MyVMName"
  os_type  = "linux"

  command = "touch /it-works.txt && echo 'it works!' >> /it-works.txt"
}
```

### Install Chocolatey (Windows)

```hcl
resource "azurerm_resource_group" "vm-rg" {
  name     = "vm-rg"
  location = "UK South"
}

resource "azurerm_windows_virtual_machine" "win_vm" {
  
  name                  = var.vm_name
  resource_group_name   = azurerm_resource_group.vm_rg.name
  location              = azurerm_resource_group.vm_rg.location
  ......
  
module "run_command" {
  source               = "craigthackerx/terraform-azurerm-vm-run-command/PostInstall"
  rg_name              = azurerm_resource_group.win_vm.name
  vm_name              = azurerm_windows_virtual_machine.win_vm.name
  location             = azurerm_resource_group.win_vm.name
  os_type              = "windows"

  command = "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))"
}
```

### Install Git (Linux)

```hcl
resource "azurerm_resource_group" "vm-rg" {
  name     = "vm-rg"
  location = "UK West"
}

resource "azurerm_linux_virtual_machine" "linux_vm" {
  
  name                  = "MyVM"
  resource_group_name   = azurerm_resource_group.vm_rg.name
  location              = azurerm_resource_group.vm_rg.location
  ......
  

module "run_command" {
  source               = "https://github.com/craigthackerx/terraform-azurerm-vm-run-command/PostInstall"
  rg_name              = azurerm_resource_group.vm-rg.name
  vm_name              = azurerm_linux_virtual_machine.linux_vm.name
  os_type              = "linux"

  script = <<EOF
apt-get update && \
apt-get install -y git
EOF
}
```

### Install Updates (Windows)

```hcl
module "run_command" {
  source               = "craigthackerx/terraform-azurerm-vm-run-command/PostInstall"
  rg_name              = azurerm_resource_group.main.name
  vm_name              = azurerm_windows_virtual_machine.main.name
  location             = "US West"
  os_type              = "windows"

  script = <<EOF
Install-Module -Name PSWindowsUpdate -Force -AllowClobber
Get-WUInstall -WindowsUpdate -AcceptAll -UpdateType Software -IgnoreReboot
Get-WUInstall -MicrosoftUpdate -AcceptAll -IgnoreUserInput -IgnoreReboot
EOF
}
```

## Arguments

| Name | Type | Description |
| --- | --- | --- |
| `rg_name` | `string` | The name of the resource group. |
| `vm_name` | `string` | The name of the virtual machine. |
| `location` | `string` | The location of the extension resource - Must match host |
| `os_type` | `string` | The name of the operating system. Possible values are: `linux` and `windows`. |
| `command` | `string` | The command to be executed. |
| `script` | `string` | The script to be executed. Either this or `command` should be specified, but not both. |
| `file_uris` | `list` | List of URLs for files to be downloaded. |
| `timestamp` | `string` | Change this value to trigger a rerun of the script. Any integer value is acceptable, it must only be different than the previous value. |


