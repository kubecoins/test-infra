terraform {
  required_version = ">= 0.13.0"

  backend "s3" {
      region = "eu-west-2"
      bucket = "kubecoins-test-infra-state"
      key = "terraform.tfstate"
      dynamodb_table = "kubecoins-test-infra-state-lock"
      encrypt = "true"
  }
}