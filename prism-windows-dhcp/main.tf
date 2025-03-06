# terraform {
#   required_providers {
#     nutanix = {
#       source  = "nutanix/nutanix"
#       version = "1.8.1"
#     }
#   }
# }
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
  template = file("${path.module}/unattend.xml")
  vars = {
    vm_name             = var.t_vm_name
    hostname            = var.t_hostname
    admin_username      = var.t_admin_username
    admin_password      = var.t_admin_password
  }
}

data "template_file" "unattend2" {
  template = file("${path.module}/unattend.xml")
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