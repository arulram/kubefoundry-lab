output "lab_name" {
  value = local.lab_name
}

output "node_count" {
  value = local.node_count
}

output "node_inventory_files" {
  value = {
    for name, node in local_file.node_inventory :
    name => node.filename
  }
}
