variable "region" {
  description = "Region de replicación."
  type        = string
  default     = "us-west-2"
}

variable "bucket_name" {
  description = "(Optional, Forces new resource) The name of the bucket."
  type        = string
}

variable "tags" {
  type        = map(any)
  description = "Tags to assign to the bucket."
}
