```hcl
###############################
# main.tf
###############################
locals {
  # Turn the list into a predictable map for for_each
  cmd_map = {
    for idx, cmd in var.commands :
    coalesce(cmd.name, "run-command-${idx + 1}") => cmd
  }
}

#########################################
# Windows Run-Command (only if windows)
#########################################
resource "azurerm_virtual_machine_run_command" "windows" {
  for_each = lower(var.os_type) == "windows" ? local.cmd_map : {}

  name               = each.key
  location           = var.location
  virtual_machine_id = var.vm_id
  tags               = var.tags

  run_as_user     = try(each.value.run_as_user, null)
  run_as_password = try(each.value.run_as_password, null)

  ######################################
  # pick exactly one source
  ######################################
  dynamic "source" {
    for_each = try(each.value.inline, null) != null ? [1] : []
    content { script = each.value.inline }
  }
  dynamic "source" {
    for_each = try(each.value.script_file, null) != null ? [1] : []
    content { script = file(each.value.script_file) }
  }
  dynamic "source" {
    for_each = try(each.value.script_uri, null) != null ? [1] : []
    content { script_uri = each.value.script_uri }
  }

  lifecycle {
    precondition {
      condition = length(compact([
        try(each.value.inline, null),
        try(each.value.script_file, null),
        try(each.value.script_uri, null)
      ])) == 1
      error_message = "Command '${each.key}' must set exactly ONE of inline, script_file, or script_uri."
    }
  }
}

#########################################
# Linux Run-Command (only if linux)
#########################################
resource "azurerm_virtual_machine_run_command" "linux" {
  for_each = lower(var.os_type) == "linux" ? local.cmd_map : {}

  name               = each.key
  location           = var.location
  virtual_machine_id = var.vm_id
  tags               = var.tags

  run_as_user     = try(each.value.run_as_user, null)
  run_as_password = try(each.value.run_as_password, null)

  # identical source logic -------------------------
  dynamic "source" {
    for_each = try(each.value.inline, null) != null ? [1] : []
    content { script = each.value.inline }
  }
  dynamic "source" {
    for_each = try(each.value.script_file, null) != null ? [1] : []
    content { script = file(each.value.script_file) }
  }
  dynamic "source" {
    for_each = try(each.value.script_uri, null) != null ? [1] : []
    content { script_uri = each.value.script_uri }
  }

  lifecycle {
    precondition {
      condition = length(compact([
        try(each.value.inline, null),
        try(each.value.script_file, null),
        try(each.value.script_uri, null)
      ])) == 1
      error_message = "Command '${each.key}' must set exactly ONE of inline, script_file, or script_uri."
    }
  }
}
```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_virtual_machine_run_command.linux](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_run_command) | resource |
| [azurerm_virtual_machine_run_command.windows](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_run_command) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_commands"></a> [commands](#input\_commands) | One-or-many commands to run on the VM | <pre>list(object({<br/>    name            = optional(string) # extension name; auto when null<br/>    inline          = optional(string)<br/>    script_file     = optional(string)<br/>    script_uri      = optional(string)<br/>    run_as_user     = optional(string)<br/>    run_as_password = optional(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region (same as the VM) | `string` | n/a | yes |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | Operating system of the VM: windows \| linux | `string` | `"windows"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to every Run-Command resource | `map(string)` | `{}` | no |
| <a name="input_vm_id"></a> [vm\_id](#input\_vm\_id) | ID of the VM the commands should run on | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm_run_command_ids"></a> [vm\_run\_command\_ids](#output\_vm\_run\_command\_ids) | Resource IDs of all azurerm\_virtual\_machine\_run\_command objects |
| <a name="output_vm_run_command_instance_view"></a> [vm\_run\_command\_instance\_view](#output\_vm\_run\_command\_instance\_view) | Instance-view information for each run-command |
| <a name="output_vm_run_command_locations"></a> [vm\_run\_command\_locations](#output\_vm\_run\_command\_locations) | Azure region where each run-command resource is created |
| <a name="output_vm_run_command_names"></a> [vm\_run\_command\_names](#output\_vm\_run\_command\_names) | Name property of each run-command resource |
| <a name="output_vm_run_command_script_uris"></a> [vm\_run\_command\_script\_uris](#output\_vm\_run\_command\_script\_uris) | script\_uri values for commands defined via script\_uri |
| <a name="output_vm_run_command_scripts"></a> [vm\_run\_command\_scripts](#output\_vm\_run\_command\_scripts) | Inline script content for commands defined via inline or script\_file |
