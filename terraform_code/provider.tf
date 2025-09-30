terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.9.10"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://192.168.0.2:8006/api2/json"
  pm_tls_insecure = true
  pm_timeout = 1000
}