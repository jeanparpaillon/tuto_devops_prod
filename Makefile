
PYTHON := $(shell asdf where python)/bin/python3
VENV := .venv

TERRAFORM_DIR := $(abspath ./terraform)
ANSIBLE_DIR := $(abspath ./ansible)
TF_INVENTORY := $(ANSIBLE_DIR)/terraform.yml
ANSIBLE_PLAYBOOK := site.yml
MOLECULE_SCENARIO := k8s_cluster

all:

clean: tf-destroy ansible-clean venv-clean

setup: ansible-setup

setup-env: | $(VENV)

$(VENV):
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

ansible-setup: ansible-galaxy

ansible-galaxy: setup-env
	cd $(ANSIBLE_DIR) && ansible-galaxy install -r requirements.yml

ansible-inventory: $(TF_INVENTORY)
	ansible-inventory --list

$(TF_INVENTORY): $(TF_INVENTORY).in
	sed "s|@TF_PROJECT_PATH@|$(TERRAFORM_DIR)|g" $< > $@

ansible-playbook:
	cd $(ANSIBLE_DIR) && ansible-playbook playbooks/$(ANSIBLE_PLAYBOOK)

ansible-verify:
	cd $(ANSIBLE_DIR) && ansible-playbook playbooks/$(ANSIBLE_PLAYBOOK) --tags verify

ansible-clean:
	rm -f $(TF_INVENTORY)

molecule-test:
	cd $(ANSIBLE_DIR)/roles/master && molecule test -s $(MOLECULE_SCENARIO) --destroy=never

molecule-converge:
	cd $(ANSIBLE_DIR)/roles/master && molecule converge -s $(MOLECULE_SCENARIO)

molecule-verify:
	cd $(ANSIBLE_DIR)/roles/master && molecule verify -s $(MOLECULE_SCENARIO)

molecule-reset:
	cd $(ANSIBLE_DIR)/roles/master && molecule reset -s $(MOLECULE_SCENARIO)

venv-clean:
	rm -rf $(VENV)
	find . -type d -name "__pycache__" -exec rm -rf {} +

.PHONY: all destroy clean inventory setup activate venv-clean
.PHONY: tf-init tf-plan tf-apply tf-output tf-destroy tf-console
.PHONY: ansible-inventory ansible-galaxy ansible-setup ansible-clean ansible-playbook ansible-verify
.PHONY: molecule-test molecule-converge molecule-verify molecule-reset
