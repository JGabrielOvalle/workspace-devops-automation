variable "resource_group_name" {
  description = "Nome do Resource Group"
  type = string
  default = "rg-vm-automation"
}

variable "location" {
  description = "Localização dos recursos"
  type = string
  default = "East US"
}

variable "admin_password" {
    description = "Senha do administrador"
    type = string
    sensitive = true
    default = "Mudar123@#$"
}