resource "local_file" "lesson_output" {
  filename = "${path.module}/hello.txt"
  content  = var.message
}
