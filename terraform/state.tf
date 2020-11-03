terraform {
  backend "s3" {
    bucket         = "infra-aws-backups-state-598097830519"
    key            = "terraform/deploy.tfstate"
    dynamodb_table = "infra-aws-backups-state-598097830519"
    region         = "us-west-2"
  }
}
