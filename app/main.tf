module "app-rgp" {
  source = "../modules/rgp"
  azloc = "East US"
  rgpname = "ODL-azure-793001"
}

module "app-vnet" {
  source = "../modules/network"
  azloc = module.app-rgp.rgp_azloc
  rgpname = module.app-rgp.rgp_name
  vnet_name = "app_vnet"
}

module "application1" {
  source = "../modules/web"
  azloc = module.app-rgp.rgp_azloc
  rgpname = module.app-rgp.rgp_name
  app_subnetid = module.app-vnet.subnet_id
  pip_lb  = "webapp-eastus"
  app_nsg = module.app-vnet.app_nsg_id
  depends_on = [
    module.app-rgp,
    module.app-vnet
  ]
}

module "sql1" {
  source = "../modules/sql"
  azloc = module.app-rgp.rgp_azloc
  rgpname = module.app-rgp.rgp_name
  be_subnetid = module.app-vnet.be_subnet_id
  depends_on = [
    module.app-rgp,
    module.app-vnet
  ]
}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=3.0.1"
    }
  }
}
provider "azurerm" {
  features {}
}