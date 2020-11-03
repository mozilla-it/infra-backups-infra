
locals {
  iam_username       = var.iam_username == "" ? var.bucket_name : var.iam_username
  backup_policy_name = "bacula-backups"

  tags = {
    "Region"    = var.region
    "Terraform" = "true"
  }
}

resource "aws_s3_bucket" "this" {
  count  = var.enabled ? 1 : 0
  bucket = var.bucket_name
  tags   = merge({ "Name" = var.bucket_name }, local.tags)
}

resource "aws_iam_user" "this" {
  count = var.enabled && var.create_iam_user ? 1 : 0
  name  = local.iam_username
  tags  = merge({ "Name" = local.iam_username }, local.tags)
}

resource "aws_iam_access_key" "this" {
  count = var.enabled && var.create_iam_user && var.create_iam_key ? 1 : 0
  user  = aws_iam_user.this[0].name
}

resource "aws_iam_user_policy" "this" {
  count  = var.enabled && var.create_iam_user ? 1 : 0
  name   = local.backup_policy_name
  user   = aws_iam_user.this[0].name
  policy = data.aws_iam_policy_document.this[0].json
}
