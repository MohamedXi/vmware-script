import requests
import urllib3
from vmware.vapi.vsphere.client import create_vsphere_client
from com.vmware.vcenter.vm_client import Power
from com.vmware.vcenter_client import VM
import json


def get_vm(client, vm_name):
    """
    Return the identifier of a vm
    Note: The method assumes that there is only one vm with the mentioned name.
    """
    names = set([vm_name])
    vms = client.vcenter.VM.list(VM.FilterSpec(names=names))
    if len(vms) == 0:
        print("VM with name ({}) not found".format(vm_name))
        return None
    vm = vms[0].vm
    print("Found VM '{}' ({})".format(vm_name, vm))
    return vm


session = requests.session()
# Disable cert verification for demo purpose.
# This is not recommended in a production environment.
session.verify = False
# Disable the secure connection warning for demo purpose.
# This is not recommended in a production environment.
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
# Connect to a vCenter Server using username and password
vsphere_client = create_vsphere_client(server='vcenter01.cloudis222353.lan', username='administrator@vsphere.local',
                                       password='P@ssw0rd', session=session)
# List all VMs inside the vCenter Server
# print(vsphere_client.vcenter.__dict__)
# print(vsphere_client.vcenter.Network.list())
# print(vsphere_client.vcenter.Host.list())
# print(vsphere_client.vcenter.Network.list()[0])
# print(vsphere_client.vcenter.Host.list()[0])
vms = vsphere_client.vcenter.VM.list()
for vm in vms:
    print(vm)
    print('VM-Number: ' + vm.vm)
    print('VM-Name: ' + vm.name)
    print('VM-State: ' + vm.power_state)
    print('VM-Cpu number: ' + str(vm.cpu_count))
    print('VM-Ram: ' + str(vm.memory_size_mib))
    myvm = get_vm(vsphere_client, vm.name)
    # Delete virtual machine
    # result = vsphere_client.vcenter.VM.delete(myvm)

    # Reset virtual machine
    # result = vsphere_client.vcenter.vm.Power.reset(myvm)
    print(result)