output "ip" {
  value = vsphere_virtual_machine.vm001.guest_ip_addresses[0]
}

# TODO: Generate the output to ansible inventory
# Source: https://stackoverflow.com/questions/45489534/best-way-currently-to-create-an-ansible-inventory-from-terraform
