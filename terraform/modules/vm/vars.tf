variable "vm_names" {
  description = "List of names for the virtual machines."
  type        = list(string)
  default     = []
}

variable "subnet_id" {
  description = "The ID of the subnet where the VMs will be deployed."
  type        = string
}

variable "location" {
    description = "The Azure region where resources will be deployed."
    type        = string
    default     = "East US 2"
}