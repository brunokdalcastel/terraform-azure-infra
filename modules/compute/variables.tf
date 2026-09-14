variable "resource_group_name" {
  description = "Nome do Resource Group"
  type        = string
}

variable "location" {
  description = "Localização dos recursos"
  type        = string
}

variable "name_prefix" {
  description = "Prefixo para nomes dos recursos"
  type        = string
}

variable "vm_count" {
  description = "Número de VMs"
  type        = number
  nullable    = false
  validation {
    condition     = var.vm_count >= 0 && floor(var.vm_count) == var.vm_count
    error_message = "vm_count deve ser um inteiro não negativo."
  }
}

variable "vm_size" {
  description = "Tamanho das VMs"
  type        = string
}

variable "admin_username" {
  description = "Username do admin"
  type        = string
}

variable "vm_image" {
  description = "Imagem do SO"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "subnet_id" {
  description = "ID da subnet"
  type        = string
}

variable "admin_ssh_public_key" {
  description = "Chave pública RSA OpenSSH do operador. Nunca fornecer a chave privada."
  type        = string
  default     = ""
  nullable    = false
  validation {
    condition     = var.vm_count == 0 || can(regex("^ssh-rsa [A-Za-z0-9+/]+={0,3}( .*)?$", trimspace(var.admin_ssh_public_key)))
    error_message = "VMs habilitadas exigem chave pública RSA OpenSSH; o provider valida o material da chave."
  }
}
variable "tags" {
  description = "Tags dos recursos"
  type        = map(string)
}
