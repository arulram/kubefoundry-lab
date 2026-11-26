locals {
  lab_name   = "kubefoundry"
  node_count = length(var.nodes)
}

resource "local_file" "node_inventory" {
  # iterates over the four entries and creates four instances of local_file.node_inventory
  for_each = var.nodes

  filename = "${path.module}/${each.key}.txt"

  content = <<-EOT
    Lab: ${local.lab_name}
    Node: ${each.key}
    Role: ${each.value.role}
    vCPU: ${each.value.vcpu}
    Memory: ${each.value.memory_mb} MB
    Disk: ${each.value.disk_gb} GB
  EOT

  file_permission = "0644"
}
