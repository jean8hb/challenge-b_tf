variable "region" {
  description = "Region principal."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "(Opcional al forzar nuevos buckets) Nombre del bucket"
  type        = string
}

variable "tags" {
  type        = map(any)
  description = "Tags a asignar al(los) bucket(s)."
}

variable "block_public_acls" {
  description = "Bloquea acceso público mediante ACL."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Bloquea acceso público mediante política."
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Restringe acceso público."
  type        = bool
  default     = true
}

variable "replication_enabled" {
  type    = bool
  default = true
}

variable "replication_bucket" {
  description = "El bucket de destino para la replicación en otra región."
  type        = string
}

variable "replication_role" {
  description = "El ARN del rol IAM para la replicación."
  type        = string
}
