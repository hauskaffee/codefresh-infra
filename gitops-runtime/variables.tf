variable "codefresh_token" {
  description = "API Token for the Codefresh System"
  sensitive   = true
}

variable "codefresh_account" {
  description = "Account ID of the Codefresh Account"
  sensitive   = true
}

variable "gh_username" {
  description = "githubs username"
  sensitive   = true
}

variable "gh_pat" {
  description = "github token"
  sensitive   = true
}
