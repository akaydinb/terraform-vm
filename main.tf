provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_pass
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
  api_timeout          = 10
}

resource "vsphere_virtual_machine" "vm001" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = var.number_of_cpus
  memory           = var.amount_memory_mb
  guest_id         = "otherLinux64Guest"
  #scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  network_interface {
    network_id = data.vsphere_network.network_ext.id
    # external network i.e. internet facing interface
  }
  network_interface {
    network_id = data.vsphere_network.network_pro.id
    # provisioning network
  }
  network_interface {
    network_id = data.vsphere_network.network_int.id
    # internal network, trunk int. VLAN 150 on subnet 10.200.16.96/29
  }
  disk {
    label            = "Hard Disk 1"
    size             = var.disksize_gb
    thin_provisioned = true
  }
  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
    customize {
      linux_options {
        host_name = var.vm_name
        domain   = var.domainname
      }
      network_interface {
        ipv4_address = var.ipv4_address[0]
        ipv4_netmask = var.ipv4_netmask[0]
        # Internet
      }
      network_interface {
        ipv4_address = var.ipv4_address[1]
        ipv4_netmask = var.ipv4_netmask[1]
        # Provisioning
      }
      network_interface {
        ipv4_address = var.ipv4_address[2]
        ipv4_netmask = var.ipv4_netmask[2]
        # Internal
      }
      ipv4_gateway = var.ipv4_gateway
    }
  }
  extra_config = {
    "guestinfo.metadata"          = base64encode(templatefile("${path.cwd}/templates/metadata.yaml", local.templatevars))
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata"          = base64encode(templatefile("${path.cwd}/templates/userdata.yaml", local.templatevars))
    "guestinfo.userdata.encoding" = "base64"
    # path.cwd is recommended over path.module
  }
  lifecycle {
    ignore_changes = [
      annotation,
      clone[0].template_uuid,
      clone[0].customize[0].dns_server_list,
      clone[0].customize[0].network_interface[0]
    ]
  }
}

locals {
  templatevars = {
    name         = var.vm_name,
    ipv4_address = var.ipv4_address[1],
    ipv4_gateway = var.ipv4_gateway,
    dns_server_1 = var.dns_server_list[0],
    dns_server_2 = var.dns_server_list[1],
    public_key = var.public_key,
    ssh_username = var.ssh_username
  }
}
# Ref: https://tekanaid.com/posts/terraform-create-ubuntu22-04-vm-vmware-vsphere/
