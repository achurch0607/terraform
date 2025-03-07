terraform {
  required_providers {
    nutanix = {
      source  = "nutanix/nutanix"
      version = "2.0.0"
    }
  }
}
# zet provider, Nutanix
provider "nutanix" {
  username     = var.nutanix_username
  password     = var.nutanix_password
  endpoint     = var.nutanix_endpoint
  insecure     = true
  wait_timeout = 60
  port         = 9440
}

# Dataveld voor nutanix_cluster registreren, zodat id e.d. gehaald kan worden van cluster
data "nutanix_cluster" "cluster" {
  name = var.nutanix_cluster
}

# Dataveld voor nutanix_subnet registreren, zodat id e.d. gehaald kan worden van subnets
data "nutanix_subnet" "subnet" {
  subnet_name = var.subnet_name
}

# Dataveld voor nutanix_image registreren, zodat id e.d. gehaald kan worden van image naam
data "nutanix_image" "image" {
  image_name = var.nutanix_imagename
}

# unattend.xml template vertalen mag niet in een subdirectory staan voor Morpheus
data "template_file" "unattend" {
  template = file("unattend.xml")
  vars = {
    vm_name             = var.t_vm_name
    hostname            = var.t_hostname
    admin_username      = var.t_admin_username
    admin_password      = var.t_admin_password
  }
}

data "template_file" "unattend2" {
  template = file("unattend.xml")
  vars = {
    vm_name             = format("%s.%s",var.t_vm_name,"2")
    hostname            = format("%s.%s",var.t_hostname,"2")
    admin_username      = var.t_admin_username
    admin_password      = var.t_admin_password
  }
}

resource "nutanix_virtual_machine" "vm" {
  #  count                = 1
  name                 = var.t_vm_name
  description          = var.t_vm_description
  provider             = nutanix
  cluster_uuid         = data.nutanix_cluster.cluster.id
  num_vcpus_per_socket = var.t_num_vcpus_per_socket
  num_sockets          = var.t_num_sockets
  memory_size_mib      = var.t_memory_size_mib
  boot_type            = var.t_boot_type

  # Zet categorien op Nutanix

  # koppel de NIC, op basis van het ID van de variabele
  nic_list {
    # subnet_reference is saying, which VLAN/network do you want to attach here?
    # Networks, Subnets, edit, UUID
    subnet_uuid = data.nutanix_subnet.subnet.id
  }

  # Unattend.xml op basis van template
  guest_customization_sysprep = {
    install_type = "PREPARED"
    unattend_xml = base64encode(data.template_file.unattend.rendered)
  }

  # image referentie die uitgerold wordt
  disk_list {
    data_source_reference = {
      kind = "image"
      uuid = data.nutanix_image.image.id
    }
  }

  # diskgrootte zetten van een 2e disk
  disk_list {
    #disk_size_bytes = 40 * 1024 * 1024 * 1024
    disk_size_bytes = var.t_disk_2_size
    device_properties {
      device_type = "DISK"
      disk_address = {
        "adapter_type" = "SCSI"
        "device_index" = "1"
      }
    }

    # # refereer naar de opslag locatie waar de VM wordt gekopieerd
    # storage_config {
    #   storage_container_reference {
    #     kind = "storage_container"
    #     uuid = var.nutanix_storagecontainer_uuid
    #   }
    # }
  }
  #  provisioner "local-exec" {
  #    command = <<EOT
  #    echo "not doing anything anymore"
  #    EOT
  #  }
}

resource "nutanix_virtual_machine" "vm2" {
  #  count                = 1
  name                 = format("%s.%s",var.t_vm_name,"2")
  description          = var.t_vm_description
  provider             = nutanix
  cluster_uuid         = data.nutanix_cluster.cluster.id
  num_vcpus_per_socket = var.t_num_vcpus_per_socket
  num_sockets          = var.t_num_sockets
  memory_size_mib      = var.t_memory_size_mib
  boot_type            = var.t_boot_type

  # Zet categorien op Nutanix

  # koppel de NIC, op basis van het ID van de variabele
  nic_list {
    # subnet_reference is saying, which VLAN/network do you want to attach here?
    # Networks, Subnets, edit, UUID
    subnet_uuid = data.nutanix_subnet.subnet.id
  }

  # Unattend.xml op basis van template
  guest_customization_sysprep = {
    install_type = "PREPARED"
    unattend_xml = base64encode(data.template_file.unattend2.rendered)
  }

  # image referentie die uitgerold wordt
  disk_list {
    data_source_reference = {
      kind = "image"
      uuid = data.nutanix_image.image.id
    }
  }

  # diskgrootte zetten van een 2e disk
  disk_list {
    #disk_size_bytes = 40 * 1024 * 1024 * 1024
    disk_size_bytes = var.t_disk_2_size
    device_properties {
      device_type = "DISK"
      disk_address = {
        "adapter_type" = "SCSI"
        "device_index" = "1"
      }
    }

    # # refereer naar de opslag locatie waar de VM wordt gekopieerd
    # storage_config {
    #   storage_container_reference {
    #     kind = "storage_container"
    #     uuid = var.nutanix_storagecontainer_uuid
    #   }
    # }
  }
  #  provisioner "local-exec" {
  #    command = <<EOT
  #    echo "not doing anything anymore"
  #    EOT
  #  }
}


output "VMID" {
  value = nutanix_virtual_machine.vm
}


output "ip_address" {
  value = nutanix_virtual_machine.vm.nic_list_status.0.ip_endpoint_list[0]["ip"]
}


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

