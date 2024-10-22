#######################################################################
# vCenter login details
#######################################################################

variable "vsphere_user" {
    description = "vSphere user to login with"
    type        = string
    sensitive   = true
    # use TF_VAR_vsphere_user env. var. for this
}

variable "vsphere_pass" {
    description = "vSphere password of above user"
    type        = string
    sensitive   = true
    # use TF_VAR_vsphere_pass env. var. for this
}

variable "vsphere_server" {
  default = "dcvcent01p.lab.local"
    description = "vCenter instance hostname or IP"
}

#######################################################################
data "vsphere_datacenter" "datacenter" {
  name = "DC-Neumarkt"
}

data "vsphere_datastore" "datastore" {
  name          = "Datastore01"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "LINUX"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network_ext" {
  name          = "DMZ"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network_pro" {
  name          = "Provisioning"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network_int" {
  name          = "Internalnet"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "template" {
  name          = "${var.template_name}"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

#######################################################################
# VM specific variables
#######################################################################

variable "vm_name"  {
    default     = "test_vm_ubuntu"
    description = "vm name to be created"
}

variable "number_of_cpus"  {
    default     = 2
    description = "VM Number of total cpus (dividable by num. of cores per socket)"
}

variable "number_of_cores_per_socket"  {
    default     = 1
    description = "VM Number of cores per socket"
}

variable "amount_memory_mb" {
    default     = 8192
    description = "Amount of memory in MB"
}

variable "disksize_gb"  {
    default     = 32
    description = "Disk size in GB"
}

variable "domainname"   {
    default     = "localdomain"
    description = "Domainname for the VM to be created"
}

variable "template_name"   {
    default     = "ubuntu-template-mini"
    description = "Template name to clone as VM"
}

variable "ipv4_address"   {
    type        = list(string)
    default     = ["1.2.3.4", "172.18.186.104", "10.200.16.101"]
    description = "IP Address interfaces (ext, prov, int)"
}

variable "ipv4_netmask"   {
    type        = list(string)
    default     = ["24", "24", "29"]
    description = "IP Address interfaces (ext, prov, int)"
}

variable "ipv4_gateway"   {
    type        = string
    default     = "1.2.3.1"
    description = "Default gateway on internet facing interface"
}

variable "dns_server_list" {
    type        = list(string)
    default     = ["8.8.8.8", "8.8.4.4"]
    description = "List of DNS servers"
}

variable "public_key"   {
    default     = "AAAAB3NzaC1yc2EAAAADAQABAAABAQDGXxN5vwftB1gIh3GzwVwon69tRiL9fb//X9EtVhtUV9xUB0/+mRClTEP1tCMRnaRTurLoM7kmwSa84LtjVzvMWUBWiwe9DX317jkmVaizOZPnSmTmVFZF0GvAFJ8YV/hoBznGbygSY6J2702/cQ/mxsRLeY6m9CnxgwN8qYmGvaCbUVEEMlUBkvcdjhYe2n+mZ6WTo4LE475ak/VcnI+zbFH+tIewBAdF5I2xzJwqRKKI4E/RLCELxFGYkEQJmS48g6H/T6HP8odTWofpZNYNEsP7kkzn7D3uvAL57+beaoYgnjh8j2kUp+LpAQx3MJIle3dh7hmoyM8dNAABdI8p"
    description = "Public Key of root user for initial setup"
}

variable "ssh_username" {
    type        = string
    default     = "root"
    description = "Use root for initial setup (and initial setup only)"
}
