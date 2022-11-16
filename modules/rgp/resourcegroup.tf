resource "azurerm_resource_group" "mainapp" {
  name     = var.rgpname
  location = var.azloc
  # lifecycle {
  #   prevent_destroy = true
  #   ignore_changes = [
  #     location,
  #   ]
  # }
}

