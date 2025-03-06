variable "t_vm_description" {
  description = "Nutanix VM description"
  type        = string
  sensitive   = false
}

# variable "t_ipv4_address" {
#   description = "IPv4 van VM"
#   type        = string
#   sensitive   = false
#   default = "10.126.40.149"
# }

variable "t_vm_name" {
  description = "Nutanix VM name van VM in CAPITALS"
  type        = string
  sensitive   = false
}

variable "t_hostname" {
  description = "hostnaam van VM"
  type        = string
  sensitive   = false
}

variable "subnet_name" {
  description = "NIC VLAN name"
  type        = string
  sensitive   = false
}

# variable "t_ipv4_gateway" {
#   description = "IPv4 gateway van VM"
#   type        = string
#   default = "10.126.40.1"
# }

# variable "t_ipv4_mask" {
#   description = "IPv4 subnetmask van VM"
#   type        = string
#   default = "255.255.255.0"
# }

# variable "t_ipv4_maskbits" {
#   description = "IPv4 subnetmaskbits van VM"
#   type        = string
# }

variable "nutanix_imagename" {
  description = "Name of image for VM"
  type        = string
  sensitive   = false
}

variable "t_num_vcpus_per_socket" {
  description = "Nutanix VM vCores per socket, laat deze op 1 staan"
  type        = string
  default     = "1"
}

variable "t_num_sockets" {
  description = "Nutanix VM vCPU's"
  type        = string
}

variable "t_memory_size_mib" {
  description = "Nutanix VM vMEM"
  type        = string
}

variable "t_disk_2_size" {
  description = "Nutanix VM data disk 2"
  type        = number
}

variable "t_boot_type" {
  description = "Nutanix VM Boottype"
  type        = string
  default     = "UEFI"
}

# variable "t_ipv4_nameservers" {
#   description = "IPv4 nameservers van VM"
#   type        = string
#   default = "10.126.0.2"
# }

# variable "t_ntpserver" {
#   description = "NTP Server"
#   type        = string
#   default = "north-america.pool.ntp.org"
# }

# variable "t_domain" {
#   description = "IPv4 search domein van VM"
#   type        = string
# }

# variable "vm_domain" {
#   description = "Name of domain for VMs"
#   type        = string
#   sensitive   = false
# }

# Windows Authentication
variable "t_admin_username" {
  description = "Name of domain for VMs"
  type        = string
  sensitive   = true
  default     = "Administrator"
}

variable "t_admin_password" {
  description = "Name of domain for VMs"
  type        = string
  sensitive   = true
}

# variable "t_admin_unenc" {
#   description = "Unencrypted pwd"
#   type        = string
#   sensitive   = true
# }

# Nutanix cluster definitie
variable "nutanix_endpoint" {
  description = "Nutanix endpoint"
  type        = string
  sensitive   = false
}

variable "nutanix_cluster" {
  description = "Nutanix Cluster"
  type        = string
  sensitive   = false
}

# variable "nutanix_storagecontainer_uuid" {
#   description = "Name of Storage Container" 
#   type        = string
#   sensitive   = false
# }

# redelijk statisch vanaf hier ;-)
variable "nutanix_username" {
  description = "Nutanix user"
  type        = string
  sensitive   = true
}

variable "nutanix_password" {
  description = "Nutanix password"
  type        = string
  sensitive   = true
}

# variable "aap_token" {
#   description = "AAP token"
#   type        = string
#   sensitive   = true
# }
 
