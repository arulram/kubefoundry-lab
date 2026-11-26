output "lab_name" {
  description = "Learning lab name"
  value       = var.lab_name
}

output "message_file" {
  description = "Path of the message file"
  value       = local_file.lesson_message.filename
}

output "summary_file" {
  description = "Path of the summary file"
  value       = local_file.lesson_summary.filename
}
