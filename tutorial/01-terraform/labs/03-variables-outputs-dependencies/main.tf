resource "local_file" "lesson_message" {
  filename        = "${path.module}/${var.lab_name}-message.txt"
  content         = var.message
  file_permission = "0644"
}

resource "local_file" "lesson_summary" {
  filename        = "${path.module}/${var.lab_name}-summary.txt"
  content         = "Message file: ${local_file.lesson_message.filename}"
  file_permission = "0644"
}
