# Global parameters
target_node = "proxmox-node"
bridge_network = "vmbr0"
bridge_cidr_range = "192.168.0.0/24"
ciuser = "ubuntu"
ssh_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDvgc/Dd8vB2DhPk2s+ptcEXktMK7P11UnqEhhIktAYGun/qX8t/WlxBMLzXEhZdDGhKryZ1Uvr6JOe5kq8sGz4NAhdG88MgZJPpCGUIo8UqtNhMjgHuzQjuFVmGLdF0ld1Xb1X0TmFPo6WLjeCt3MwoNZL/Inxbp4oP9Du614FEFtHo68IVzsJb2UJAZR1nmB//FmuzXskbew0lRmCxHJFsbx/zrWcGoma0DKBFk2mL6F/vPmM7dMHdn0JTprDF+xH9io17UQVB4mZ+VdY+PCrxuRBu9j/C0BPSWCPT/9nTN0ss4G528cyFlqwPMIzWiuIRX+kAsx0y6pap29Wd4MwkDGLbbuazY6NAJiXTkj/eKhpJ+FhSPkpYZs2d/x8JWXkSSEYn1y3Lcft1rZ2y5DvCxVviNM9B5An69unOdy4VR5hz6e2l7DcZ7Tbh9lWUmxugp4MclfT+5ToQXBL7+fx83pDgOq4lqXiRF6iw3ICJ3BD+mSoZbnj9TaI/g7pK6k= mateus@pop-os"

# Control plane nodes parameters
master_nr = 3
master_id_range = 400
master_network_range = 60 # It will be used as X.X.X.100, X.X.X.101...
master_naming = "k8s-master-demo"
master_cores = 2
master_sockets = 1
master_memory = 4096
master_disksize = "20G"

# Worker nodes parameters
worker_nr = 3
worker_id_range = 500
worker_network_range = 70 # It will be used as X.X.X.200, X.X.X.201...
worker_naming = "k8s-worker-demo"
worker_cores = 1
worker_sockets = 1
worker_memory = 2048
worker_disksize = "50G"