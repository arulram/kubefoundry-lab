# Here we define a map of objects. Each object describes one Kubernetes VMs
variable "nodes" {
  description = "Kubernetes lab virtual machines"

  # map: a collection of entries identified by names such as cp1, w1, w2, and w3.
  # object: each entry has a defined structure.
  # string and number: specify the expected attribute types.

  type = map(object({
    role      = string
    vcpu      = number
    memory_mb = number
    disk_gb   = number
  }))

  default = {
    cp1 = {
      role      = "control-plane"
      vcpu      = 2
      memory_mb = 4096
      disk_gb   = 20
    }

    w1 = {
      role      = "worker"
      vcpu      = 1
      memory_mb = 4096
      disk_gb   = 15
    }

    w2 = {
      role      = "worker"
      vcpu      = 1
      memory_mb = 4096
      disk_gb   = 15
    }

    w3 = {
      role      = "worker"
      vcpu      = 1
      memory_mb = 4096
      disk_gb   = 15
    }
  }
}
