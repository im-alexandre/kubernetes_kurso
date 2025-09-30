resource "proxmox_vm_qemu" "masters" {

    count = var.master_nr
    
    # VM General Settings
    target_node = var.target_node
    vmid = var.master_id_range + count.index + 1
    name = format("%s-${count.index + 1}", var.master_naming)

    # VM Advanced General Settings
    onboot = true 

    # VM OS Settings
    clone = "ubuntu-2204-cloud-init"

    # VM System Settings
    agent = 1 
    
    # VM CPU Settings
    cores = var.master_cores
    sockets = var.master_sockets
    
    # VM Memory Settings
    memory = var.master_memory

    # Cloud-Init
    # Needed for correct state of Terraform
    ciuser = var.ciuser
    sshkeys = var.ssh_keys
    ipconfig0 = "ip=${cidrhost(var.bridge_cidr_range, var.master_network_range + count.index)}/24,gw=${cidrhost(var.bridge_cidr_range, 1)}"

    # VM Network Settings
    network {
        bridge = var.bridge_network
        model  = "virtio"
    }

    disk {
      type = "scsi"
      storage = "data"
      size = var.master_disksize
    }

    tags = "masters"

}