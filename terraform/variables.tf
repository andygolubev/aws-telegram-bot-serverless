variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "bot_token" {
  type = string
}

variable "aws_public_az_1" {
  description = "AWS Subnet public 1"
  type        = string
}

variable "aws_public_az_2" {
  description = "AWS Subnet public 2"
  type        = string
}

variable "aws_public_az_3" {
  description = "AWS Subnet public 3"
  type        = string
}

variable "ami" {
  description = "AMI"
  type        = string
}

variable "instance_type" {
  description = "EC2 size"
  type        = string
  default     = "t2.small"
}

variable "instance_type_eks" {
  description = "EKS node size"
  type        = string
  default     = "t2.small"
}