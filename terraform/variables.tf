variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "bot_token" {
  description = "Telegram Bot Token"
  type        = string
  sensitive   = true
}

variable "logging_level" {
  description = "Python logging level"
  type        = string
  default     = "CRITICAL"

  validation {
    condition     = contains(["NOTSET", "DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"], var.logging_level)
    error_message = "The logging level must be one of these values: NOTSET, DEBUG, INFO, WARNING, ERROR, CRITICAL"
  }
}

variable "log-group-retention-period" {
  description = "Log group retention period"
  type        = number
  default     = 7

  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.log-group-retention-period)
    error_message = "expected log-group-retention-period to be one of [0 1 3 5 7 14 30 60 90 120 150 180 365 400 545 731 1096 1827 2192 2557 2922 3288 3653]"
  }
}