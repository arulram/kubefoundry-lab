output "generated_file_path" {
  description = "Path of the file Terraform would create"
  value       = local_file.lesson_output.filename
}
