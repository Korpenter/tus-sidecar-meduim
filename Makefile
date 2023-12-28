include .env

init_terraform:
	@cd infra && terraform init

deploy_infra:
	@echo "Deploying infrastructure..."
	@cd infra && terraform init && \
	terraform apply -auto-approve \
	-var="yandex_token=$(YC_TOKEN)" \
	-var="yandex_cloud_id=$(YC_CLOUD_ID)" \
	-var="yandex_folder_id=$(YC_FOLDER_ID)" \
	-var="yandex_folder_id=$(YC_FOLDER_ID)" \
	-var="subnet_id=$(SUBNET_ID)" \
	-var="s3_name=$(S3_NAME)"
	@cd infra && terraform output -raw vm_external_ip > ../.tus_server_url
	@make deploy_app

deploy_app: 
	@echo "Checking Minikube status..."
	@minikube status || minikube start
	@echo "Deploying application..."
	@TUS_SERVER_URL=`cat .tus_server_url` envsubst < app-deployment.yaml | kubectl apply -f -


destroy_infra:
	@echo "Destroying infrastructure..."
	@cd infra && terraform init && \
	terraform destroy -auto-approve \
	-var="yandex_token=$(YC_TOKEN)" \
	-var="yandex_cloud_id=$(YC_CLOUD_ID)" \
	-var="yandex_folder_id=$(YC_FOLDER_ID)" \
	-var="subnet_id=$(SUBNET_ID)" \
	-var="s3_name=$(S3_NAME)"

destroy_app:
	@kubectl delete -f app-deployment.yaml

connect:
	@echo "Waiting for pods to be in the running state..."
	@kubectl wait --for=condition=Ready pod -l app=simpload --timeout=120s
	@simpload_pod=$$(kubectl get pod -l app=simpload -o jsonpath="{.items[0].metadata.name}") && \
	kubectl exec -it $$simpload_pod -c simpload -- /bin/sh

up:  deploy_infra build_images deploy_app connect

down: destroy_infra destroy_app

all: init_terraform up