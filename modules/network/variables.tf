// Resource Group

variable "rgpname" {
  type = string
}

variable "azloc" {
  type = string
}

variable "vnet_name" {
  type = string
  default = "app-vent"
}

variable "vnet_addressspace" {
  type = list(string)
  default = ["10.0.0.0/22"]
}

variable "vnet_subnet1" {
  type = string
  default = "10.0.1.0/24"
}
variable "vnet_subnet2" {
  type = string
  default = "10.0.2.0/24"
}
variable "vnet_subnet3" {
  type = string
  default = "10.0.3.0/24"
}

