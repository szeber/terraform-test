variable "awsAccessKey" {
  type        = string
  description = "The access key that is used to manage the infrastructure"
}

variable "awsSecretKey" {
  type        = string
  description = "The secret key that is used to manage the infrastructure"
}

variable "sshAllowedIp" {
  type        = string
  description = "The IP address that SSH access to the instances is allowed from"
}

variable "sshKeyName" {
  type        = string
  description = "The name of the SSH key pair that will be given access to the instances"
}
