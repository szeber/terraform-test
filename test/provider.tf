provider "aws" {
  access_key = var.awsAccessKey
  secret_key = var.awsSecretKey
  region     = local.awsRegion
}
