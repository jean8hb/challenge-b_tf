  # IMPORTANTE!
  # Recomendable usar por seguridad > export AWS_ACCESS_KEY_ID=XXXXX && AWS_SECRET_KEY=XXXXX && export AWS_DEFAULT_REGION=XXX
provider "aws" {
  region = local.region
  #llave de acceso: access_key = XXX
  #llave secreta: secret_keyy = XXX
  default_tags {
    tags = local.tags
  }
}

provider "aws" {
  alias  = "replica_provider"
  region = local.replication_region
}
