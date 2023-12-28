resource "yandex_storage_bucket" "tus-medium-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = var.s3_name
  force_destroy = true
  acl    = "public-read-write"
}