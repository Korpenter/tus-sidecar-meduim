# TUS Sidecar Article Repo
![untitled](https://github.com/Korpenter/tg-midbot/assets/141184937/c4e76ac4-ad6b-4e53-8678-8f476d43a106)

## Prerequisites

- [YC CLI](https://cloud.yandex.com/en-ru/docs/cli/operations/install-cli)
- Terraform
- Golang
- Docker
- minikube

## Quick Start

1. **Configure Terraform**  
   Follow the [Terraform Quickstart](https://cloud.yandex.com/en/docs/tutorials/infrastructure-management/terraform-quickstart) guide.

2. **Configure Docker**  
   Follow the [Docker Quickstart](https://cloud.yandex.com/en/docs/container-registry/quickstart/) guide.

5. **Deploy the tus server**  
   ```shell
   make all
   ```

6. **Connect to app container**
   ```shell
   make all
   ```

7. ** Upload a file**
   ```shell
   ./myapp upload -file file3.png
   ```

7. **Clean up**
   ```shell
   make down
   ```
