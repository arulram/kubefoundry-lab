variable "lab_name" {
  description = "Name of the learning lab"
  type        = string
  default     = "kubefoundry"
}

variable "message" {
  description = "Message to write into the first file"
  type        = string
  default     = "Learning Terraform variables and resources!"
}
