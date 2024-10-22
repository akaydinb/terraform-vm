
This terraform code creates a virtual machine on vcenter using an existing ubuntu
template. The ansible script next to it connects to newly created machine, does some
generic security hardening, then installs apache and creates a template for a given
website. 

# Directory Structure
.
├── templates
└── ansible
    └── hardening
        ├── files
        ├── tasks
        ├── templates
        └── vars

(Empty directories are ommited for simplicity.)

The root directory contains main terraform code as well as the variables needed
and a RSA key pair to connect to the VM (for ansible). The VM resource has been
defined in main.tf, with one additional interface for provisioning the VM. 

TODO: Ansible code has to disable this interface after doing its job.

After provisioning, the data needed to configure interfaces are generated
unter "templates" directory as yaml files and inserted to VM to be used by
cloud-init service. 

variables.tf contains all vCenter and vm specific data. vsphere_user and 
vsphere_pass variables must be given via TF_VAR_vsphere_user and 
TF_VAR_vsphere_pass env. vars. because of the security reasons. vCenter 
specific information is defined here and needs to be changed accordingly.
Here, it has been assumed that vSwitch of external, provisioning and 
internal networks are called "DMZ", "Provisioning" and "Internalnet"
respectively. It has also been assumed that there is an ubuntu vm template
called "ubuntu-template-mini" in the main directory of the vm datastore 
"Datastore01". This is a minimal ubuntu installation without any special
customization. The public key will be added to root using cloud-init. 

TODO: Even though terraform outputs the interface IPs to stdout, it
possibly could put the provisioning IP of the VM to "inventory.ini",
to automatize the provisioning. 

Ansible directory contains a role called hardening and it has a simple
run_hardening.yaml file to call this role. *files* subdirectory contains
a shell script to configure internal interface as trunk interface on VLAN
150. *tasks* directory contains all the tasks related to hardening and 
configuring the server.

filesdirs.yaml: Restrict the ownership of some critical files and dirs to root
firewall.yaml: Allows SSH, HTTP(S) access from internet, the traffic from
    the device and provisioning traffic. 
interfaces.yaml: Calls shell script under files, to configure the internal 
    interface as trunk. 
login.yaml: Modifies default login settings for all users. 
main. yaml: Calls other tasks respectively and reboots the machine on final step.
others.yaml: Misc hardening
sshd.yaml: Changes sshd settings. (Please see the comments inside the yaml for
    more details.)
sysctl.yaml: Applies sysctl best practices for servers
webserver.yaml: Installs apache, creates a template webpage and serves it 
    over HTTP(S). Apache config is generated based on two apache.conf 
    templates under templates/ and index.html is also generated by a
    template under same subdir. 

vars subdirectory contains customizable variables for the domain name.

# Minimum Versions and Example Run
As a prerequisite ansible.posix and community.general module collections
need to be installed for sysctl and ufw modules respectively. i.e.

ansible-galaxy collection install ansible.posix
ansible-galaxy collection install community.general

Terraform script can be easily applied by 
terraform init && terraform plan && terraform apply

Terraform script has been validated with v1.4.7 and using hashicorp/vsphere
module v2.9.3. 

Ansible has been tested with v2.16.11 (python v3.12.6). 

The script requires to external variables: 
* listen_addr: External interface IP
* intern_addr: Internal interface IP

This variables need to be given either via command line:

ansible-playbook run_hardening.yaml -e listen_addr="1.2.3.4" -e intern_addr="10.200.16.101"

or via inventory. (if I could generate ansible inventory via terraform, 
it would be definitely easier to put these vars automatically to the inv.
as well.)

22.10.2024
