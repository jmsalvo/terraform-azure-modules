variable "workload" {
  description = "Short name of the application or workload; lowercase alphanumeric, 2 to 10 characters."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{2,10}$", var.workload))
    error_message = "workload must be 2 to 10 characters, lowercase letters and digits only."
  }
}

variable "environment" {
  description = "Deployment environment; one of dev, test, stage, prod, sandbox."
  type        = string

  validation {
    condition     = contains(["dev", "test", "stage", "prod", "sandbox"], var.environment)
    error_message = "environment must be one of: dev, test, stage, prod, sandbox."
  }
}

variable "location" {
  description = "Azure region in Azure CLI short form, for example eastus2. Mapped to an abbreviation in names; unmapped values are stripped to alphanumerics and used as-is."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.location))
    error_message = "location must be lowercase alphanumeric, for example eastus2."
  }
}

variable "instance" {
  description = "Instance number for the resource set; rendered zero-padded to three digits."
  type        = number
  default     = 1

  validation {
    condition     = var.instance >= 0 && var.instance <= 999 && floor(var.instance) == var.instance
    error_message = "instance must be a whole number between 0 and 999."
  }
}

variable "suffix" {
  description = "Additional lowercase alphanumeric tokens appended to every generated name, in order."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for token in var.suffix : can(regex("^[a-z0-9]{1,10}$", token))])
    error_message = "each suffix token must be 1 to 10 characters, lowercase letters and digits only."
  }
}

variable "tags" {
  description = "Tags supplied by the caller; merged over the module baseline tags, with the caller winning on key collisions."
  type        = map(string)
  default     = {}
}

variable "cost_center" {
  description = "Optional cost center identifier; added to the baseline tags as cost_center when set."
  type        = string
  default     = null
}

variable "owner" {
  description = "Optional owner identifier such as a team name or email; added to the baseline tags as owner when set."
  type        = string
  default     = null
}
