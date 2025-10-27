
PYTHON := $(shell asdf where python)/bin/python3
VENV := .venv

TERRAFORM_DIR := ./terraform
ANSIBLE_DIR := ./ansible

all:

clean: tf-destroy venv-clean

setup:
	@echo "🚀 Setting up environment..."
	asdf install
	$(PYTHON) -m venv $(VENV)
	$(VENV)/bin/pip install --upgrade pip
	$(VENV)/bin/pip install -r requirements.txt
	@echo "✅ Done! Activate with: source $(VENV)/bin/activate"

activate:
	@echo "source $(VENV)/bin/activate"

tf-init:
	cd $(TERRAFORM_DIR) && terraform init -upgrade

tf-plan: tf-init
	cd $(TERRAFORM_DIR) && terraform plan

tf-apply: tf-init
	cd $(TERRAFORM_DIR) && terraform apply -auto-approve

tf-destroy:
	-cd $(TERRAFORM_DIR) && terraform destroy -auto-approve

tf-console:
	cd $(TERRAFORM_DIR) && terraform console

ansible-inventory:
	ansible-inventory -i $(ANSIBLE_DIR)/inventory.ini --list

venv-clean:
	rm -rf $(VENV)
	find . -type d -name "__pycache__" -exec rm -rf {} +

.PHONY: all tf-init tf-plan tf-apply tf-output tf-destroy clean tf-console ansible-inventory setup activate venv-clean