TERRAFORM_DIR := ./terraform
ANSIBLE_DIR := ./ansible

all:

clean: tf-destroy

tf-init:
	cd $(TERRAFORM_DIR) && terraform init -upgrade

tf-plan: tf-init
	cd $(TERRAFORM_DIR) && terraform plan

tf-apply: tf-init
	cd $(TERRAFORM_DIR) && terraform apply -auto-approve

tf-output: tf-apply
	(cd $(TERRAFORM_DIR) && terraform output -json k8s_nodes) > $(ANSIBLE_DIR)/inventory.json

tf-destroy:
	-cd $(TERRAFORM_DIR) && terraform destroy -auto-approve

tf-console:
	cd $(TERRAFORM_DIR) && terraform console

.PHONY: all tf-init tf-plan tf-apply tf-output tf-destroy clean tf-console