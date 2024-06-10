variable "region" {
  description = "The region to retrieve secrets"
  type        = string
}

variable "env" {
  description = "The environment to deploy to"
  type        = string
  default     = "dev"
  validation {
    condition     = var.env == "dev" || var.env == "qa" || var.env == "sbox" || var.env == "prod"
    error_message = "Invalid value"
  }
}

variable "access_key" {
  description = "Access key for AWS provider"
  type        = string
}

variable "secret_key" {
  description = "Secret key for AWS provider"
  type        = string
}