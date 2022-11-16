locals {
  first_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6wKAr7X4OFg0zPba5X0zwoLJnASP6odzmTlEyV6YJY81PHO2sxipweHU1KH7D8YUggJTpOTtlZbNFDhLpe69AozHVdnoBMKAx37WyRzTav5M5ldQauqBj5EQrhyH6/0vLgi7YrK/Y7WhfUOyi7AroUqI0mkYXBl4SdMEG/2kF/trIGacwxswOfOZPqx5h5PLnV05GBJMBGZZFlJjP5mwaSc7z49nlCVNrFH9AmHUQXCoqDjbn6NLBv/Ta15bXOhJ4bmWiD3a9HqnZzynw2+MNqj7fH31NBMaoFcjviRnXaI1p5ZZgF9594iTvTjw3OsJaYLzqnENVxdBuYB9jZ4f829WKpQZhEU4Fx0FZesGcvrGgtHANU8Jhr+n5HOs3UzO52EFo+dwwSZSTkkbNRnUq+AfO7ZTSy2DXGuQzHIS8+tg8iCYnmrUBV0ujjilLv8n1Bm9bvhJROTQ5pLEv/Q99GeFz5vcKLKdLK/cBM0t1kuI6N9g52dBZKeBh+MOriXR+eDpo/X+uDv5rAdZw1ltOQ3+xRvMWItnzIBcNWUdXSZVekSmJ2Q/6PbsN1qKVjSgdui457rOacCVU2LBg+sK61SILN/yMBRkHze1GbFYfY0fQ5hxdO0HQFgnkTaCrYHpA02uzIPeORNtIO7JETR0OwN66L8yoenF+3XvkDdDL/Q== sundeep.paluru@gmail.com"
}

# resource "azurerm_virtual_network" "example" {
#   name                = "example-network"
#   resource_group_name = azurerm_resource_group.example.name
#   location            = azurerm_resource_group.example.location
#   address_space       = ["10.0.0.0/16"]
# }

# resource "azurerm_subnet" "internal" {
#   name                 = "internal"
#   resource_group_name  = azurerm_resource_group.example.name
#   virtual_network_name = azurerm_virtual_network.example.name
#   address_prefixes     = ["10.0.2.0/24"]
# }

resource "azurerm_linux_virtual_machine_scale_set" "webapp_vms" {
  name                = "webapp-vmss"
  resource_group_name = var.rgpname
  location            = var.azloc
  sku                 = "Standard_D2s_v3"
  instances           = 2
  admin_username      = "webadmin"
  zone_balance = true
  zones = [ "1", "2", "3" ]

  admin_ssh_key {
    username   = "webadmin"
    public_key = local.first_public_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "webapp_primary_nic"
    primary = true
    enable_accelerated_networking = false #! Enable this in real world scenario.
    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.app_subnetid
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.be_pool.id]
      # load_balancer_inbound_nat_rules_ids    = [azurerm_lb_nat_pool.lbnatpool.id]
    }
  }
  depends_on = [
    azurerm_lb_backend_address_pool.be_pool
  ]
}

resource "azurerm_public_ip" "public_ip" {
  name                = var.pip_lb
  location            = var.azloc
  resource_group_name = var.rgpname
  allocation_method   = "Static"
  domain_name_label   = var.pip_lb
  sku = "Standard"
}

resource "azurerm_lb" "pub_lb" {
  name                = "${var.pip_lb}-plb"
  location            = var.azloc
  resource_group_name = var.rgpname
  sku = "Standard"
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "be_pool" {
  loadbalancer_id     = azurerm_lb.pub_lb.id
  name                = "BackEndAddressPool"
}

# resource "azurerm_lb_nat_pool" "lbnatpool" {
#   resource_group_name            = var.rgpname
#   name                           = "ssh"
#   loadbalancer_id                = azurerm_lb.pub_lb.id
#   protocol                       = "Tcp"
#   frontend_port_start            = 50000
#   frontend_port_end              = 50119
#   backend_port                   = 22
#   frontend_ip_configuration_name = "PublicIPAddress"
# }

resource "azurerm_lb_rule" "ssh_lb" {
  loadbalancer_id                = azurerm_lb.pub_lb.id
  name                           = "SSHLBRule"
  protocol                       = "Tcp"
  frontend_port                  = 2222
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids = [ azurerm_lb_backend_address_pool.be_pool.id ]
  probe_id = azurerm_lb_probe.lb_probe.id
}

resource "azurerm_lb_probe" "lb_probe" {
  loadbalancer_id     = azurerm_lb.pub_lb.id
  name                = "ssh-probe"
  protocol            = "Tcp"
  # request_path        = "/health"
  port                = 22
}

#! Network Security Group Rule
resource "azurerm_network_security_rule" "ssh_nsgrule" {
  name                        = "SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "10.0.1.0/24"
  resource_group_name         = var.rgpname
  network_security_group_name = var.app_nsg
}