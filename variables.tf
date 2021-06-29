variable "organization" {
  type        = string
  description = "The GitHub organization or user where the repo lives."
}

variable "repo" {
  type        = string
  description = "The name of the repo that the Amplify App will be created around."
}

variable "global_environment_variables" {
  default     = {}
  type        = map(string)
  description = "Environment variables that are set across all branches."
}

variable "master_environment_variables" {
  default     = {}
  type        = map(string)
  description = "Environment variables for the master branch."
}

variable "develop_environment_variables" {
  default     = {}
  type        = map(string)
  description = "Environment variables for the develop branch."
}

variable "master_branch_name" {
  default     = "master"
  type        = string
  description = "The name of the 'master'-like branch that you'd like to use."
}

variable "develop_branch_name" {
  default     = "develop"
  type        = string
  description = "The name of the 'develop'-like branch that you'd like to use."
}

variable "gh_access_token" {
  type        = string
  description = "Personal Access token for 3rd party source control system for an Amplify App, used to create webhook and read-only deploy key. Token is not stored."
}

variable "description" {
  type        = string
  description = "The description to associate with the Amplify App."
}

variable "build_spec_content" {
  default     = ""
  type        = string
  description = "Your build spec file contents. If not provided then it will use the `amplify.yml` at the root of your project / branch."
}

variable "enable_basic_auth_globally" {
  default     = false
  type        = bool
  description = "To enable basic auth for all branches or not."
}

variable "enable_basic_auth_on_master" {
  default     = false
  type        = bool
  description = "To enable basic auth the root subdomain or not."
}

variable "enable_basic_auth_on_develop" {
  default     = true
  type        = bool
  description = "To enable basic auth on the develop branch subdomain or not."
}

variable "basic_auth_username" {
  type        = string
  description = "The username to use for the basic auth configuration."
}

variable "basic_auth_password" {
  type        = string
  description = "The password to use for the basic auth configuration."
}

variable "develop_pull_request_preview" {
  default     = true
  type        = bool
  description = "Whether to enable preview on PR's into develop."
}

variable "domain_name" {
  default     = ""
  type        = string
  description = "The Custom Domain Name to associate with this Amplify App."
}

variable "custom_rules" {
  default = []
  type = list(object({
    source    = string # Required
    target    = string # Required
    status    = any    # Use null if not passing
    condition = any    # Use null if not passing
  }))
  description = "The custom rules to apply to the Amplify App."
}
