
module "bacula1-mdc1-backups" {
  source          = "./modules/bucket"
  bucket_name     = "bacula1-mdc1-backups"
  create_iam_user = true
  iam_username    = "bacula1-mdc1-backups"
  create_iam_key  = false # Set this to false because we imported the state
}

module "bacula1-mdc2-backups" {
  source          = "./modules/bucket"
  bucket_name     = "bacula1-mdc2-backups"
  create_iam_user = true
  iam_username    = "bacula1-mdc2-backups"
  create_iam_key  = false # Set this to false because we imported the state
}

module "borg-mdc1-backups" {
  source          = "./modules/bucket"
  bucket_name     = "borg-mdc1-backups"
  create_iam_user = true
  create_iam_key  = true
}
