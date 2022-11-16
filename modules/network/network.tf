resource "azurerm_network_security_group" "appsubnet_nsg" {
  name                = "app-nsg"
  location            = var.azloc
  resource_group_name = var.rgpname
}

resource "azurerm_network_security_group" "dmzsubnet_nsg" {
  name                = "dmz-nsg"
  location            = var.azloc
  resource_group_name = var.rgpname
}

resource "azurerm_network_security_group" "besubnet_nsg" {
  name                = "be-nsg"
  location            = var.azloc
  resource_group_name = var.rgpname
}

resource "azurerm_virtual_network" "appvnet" {
  name                = var.vnet_name
  location            = var.azloc
  resource_group_name = var.rgpname
  address_space       = var.vnet_addressspace

  subnet {
    name           = "appsubnet"
    address_prefix = var.vnet_subnet1
    security_group = azurerm_network_security_group.appsubnet_nsg.id
  }

  subnet {
    name           = "dmz"
    address_prefix = var.vnet_subnet2
    security_group = azurerm_network_security_group.dmzsubnet_nsg.id
  }

  subnet {
    name           = "besubnet"
    address_prefix = var.vnet_subnet3
    security_group = azurerm_network_security_group.besubnet_nsg.id
  }

  tags = {
    environment = "app-test-case"
  }
}

data "azurerm_subnet" "webapp_subnet" {
    name                 = "appsubnet"
    virtual_network_name = var.vnet_name
    resource_group_name  = var.rgpname
    depends_on = [
      azurerm_virtual_network.appvnet
    ]
}

data "azurerm_subnet" "be_subnet" {
    name                 = "besubnet"
    virtual_network_name = var.vnet_name
    resource_group_name  = var.rgpname
    depends_on = [
      azurerm_virtual_network.appvnet
    ]
}



