data "yandex_compute_image" "container-optimized-image" {
  family = "container-optimized-image"
}

data "template_file" "cloud_config" {
  template = file("${path.module}/cloud-config.yaml.tpl")

  vars = {
    ssh_public_key = file("~/.ssh/id_ed25519.pub")
  }
}


resource "yandex_compute_instance" "instance-based-on-coi" {
  name = "my-vm-tus"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.container-optimized-image.id
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  metadata = {
    user-data = data.template_file.cloud_config.rendered
    docker-compose = <<EOF
      version: "3.9"
      services:
        tusd:
          image: tusproject/tusd:v1.9
          command: -verbose -s3-bucket tustestbucket -s3-endpoint https://storage.yandexcloud.net
          volumes:
            - tusd:/data
          ports:
            - 1080:1080
          environment:
            - AWS_ACCESS_KEY_ID=${yandex_iam_service_account_static_access_key.sa-static-key.access_key}
            - AWS_SECRET_ACCESS_KEY=${yandex_iam_service_account_static_access_key.sa-static-key.secret_key}
            - AWS_REGION=ru-central1
      volumes:
        tusd:
      EOF
  }
}

output "vm_external_ip" {
  value = yandex_compute_instance.instance-based-on-coi.network_interface.0.nat_ip_address
}