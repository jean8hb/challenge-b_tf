locals {
  region      = "us-west-2"
  environment = "challenge"
  creator     = "Jean-H"
  tags = {
    Environment = local.environment
    Creator     = local.creator
  }
}
