resource "yandex_iam_service_account" "container-runner" {
  name = "container-runner"
}

resource "yandex_resourcemanager_folder_iam_member" "container_puller" {
  folder_id = var.yandex_folder_id
  member    = "serviceAccount:${yandex_iam_service_account.container-runner.id}"
  role      = "container-registry.images.puller"
}

resource "yandex_iam_service_account" "containers-manager" {
  name = "containers-manager"
}

resource "yandex_resourcemanager_folder_iam_member" "containers-invoker" {
  folder_id = var.yandex_folder_id
  member    = "serviceAccount:${yandex_iam_service_account.containers-manager.id}"
  role      = "serverless.containers.invoker"
}

resource "yandex_iam_service_account" "folder-editor" {
  name = "folder-editor"
}

resource "yandex_resourcemanager_folder_iam_member" "folder-editor" {
  folder_id = var.yandex_folder_id
  member    = "serviceAccount:${yandex_iam_service_account.folder-editor.id}"
  role      = "editor"
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.folder-editor.id
  description        = "static access key for object storage"
}

output "container_sa_id" {
  value = yandex_iam_service_account.containers-manager.id
}