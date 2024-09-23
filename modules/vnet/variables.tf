variable "location" {}
variable "virtual_network_name"{}
variable "firewall_whitelist" {}
variable "resource_group_name" {}
variable "dns_zone_resource_group" {
  type    = string
  default = "RG-Core"
}

variable "private_dns_zones" {
  type = list(string)
  default = [
    "privatelink.blob.core.windows.net",
    "privatelink.vaultcore.azure.net",
    "privatelink.file.core.windows.net"
  ]
}

variable "tags" {
  type = map(string)
}

variable "subnets" {
  type = map(object({
    name                                          = string
    virtual_network_name                          = string
    address_prefixes                              = list(string)
    private_link_service_network_policies_enabled = bool
  }))
}

variable "virtual_networks" {
  type = map(object({
    name          = string
    address_space = list(string)
    dns_servers   = list(string)
  }))
}
