# variables.tf

variable "namespace" {
  type        = string
  description = "Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'"
}

variable "stage" {
  type        = string
  description = "The environment that this infrastrcuture is being deployed to e.g. dev, stage, or prod"
}

variable "name" {
  type        = string
  description = "Solution name, e.g. 'app' or 'jenkins'"
}

variable "environment" {
  default     = ""
  type        = string
  description = "Environment, e.g. 'prod', 'staging', 'dev', 'pre-prod', 'UAT'"
}

variable "delimiter" {
  default     = "-"
  type        = string
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  default     = []
  type        = list(string)
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`"
}

variable "organization" {
  type        = string
  description = "The GitHub organization or user where the repo lives."
}

variable "repo" {
  type        = string
  description = "The name of the repo that the Amplify App will be created around."
}

variable "gh_access_token" {
  type = string
  description = "Personal Access token for 3rd party source control system for an Amplify App, used to create webhook and read-only deploy key. Token is not stored."
}

variable "description" {
  type        = string
  description = "The description to associate with the Amplify App."
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
  default = true
  type = bool
  description = "Whether to enable preview on PR's into develop."
}

variable "domain_name" {
  default = ""
  type = string
  description = "The Custom Domain Name to associate with this Amplify App."
}

variable "custom_rules" {
  default = []
  type = list(object({
    source    = string # Required
    target    = string # Required
    status    = any # Use null if not passing
    condition = any # Use null if not passing
  }))
  description = "The custom rules to apply the root."
}