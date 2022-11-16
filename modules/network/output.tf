output "vnet_name" {
  value = azurerm_virtual_network.appvnet.name
}

output "subnet_id" {
  value = data.azurerm_subnet.webapp_subnet.id
}

output "app_nsg_id" {
  value = azurerm_network_security_group.appsubnet_nsg.name
}

output "be_subnet_id" {
  value = data.azurerm_subnet.be_subnet.id
}


# output "bepool-id" {
#   value = azurerm_lb_backend_address_pool.be-pool.id
# }

# output "benat-id" {
#   value = azurerm_lb_nat_pool.lbnatpool.id
# }