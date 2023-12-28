variable "yandex_token" {
  type        = string
  description = "IAM token to for Yandex Cloud. See https://cloud.yandex.com/en/docs/iam/operations/iam-token/create"
}

variable "yandex_cloud_id" {
  type = string
}

variable "yandex_folder_id" {
  type = string
}

variable "s3_name" {
  type = string
}

variable "subnet_id" {
  type = string
}