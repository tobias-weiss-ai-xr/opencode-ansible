# OpenCode Ansible — Makefile
# Common operations for Ansible development and testing.

PLAYBOOK ?= playbooks/site.yml
INVENTORY ?= inventory/hosts.yml
LIMIT ?= localhost
TAGS ?= all
VAULT_FILE ?= ~/.ansible/vault_password

ANSIBLE_OPTS = -i $(INVENTORY) --limit $(LIMIT) --tags $(TAGS)
export ANSIBLE_ROLES_PATH = ./roles
export ANSIBLE_HOST_KEY_CHECKING = False

.PHONY: help lint try check deploy vault vault-edit clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

lint: ## Lint all playbooks + roles
	ansible-lint
	ansible-playbook --syntax-check $(PLAYBOOK) $(ANSIBLE_OPTS) 2>/dev/null || true

try: ## Dry-run against localhost
	ansible-playbook $(PLAYBOOK) $(ANSIBLE_OPTS) --connection=local --check --diff

check: ## Check mode against real hosts (no changes)
	ansible-playbook $(PLAYBOOK) $(ANSIBLE_OPTS) --check --diff

deploy: ## Deploy playbook to managed hosts
	ansible-playbook $(PLAYBOOK) $(ANSIBLE_OPTS)

vault: ## Encrypt a file with Ansible Vault
	@read -p "File to encrypt: " file; \
	ansible-vault encrypt $$file --vault-password-file $(VAULT_FILE)

vault-edit: ## Edit an encrypted vault file
	@read -p "File to decrypt: " file; \
	ansible-vault edit $$file --vault-password-file $(VAULT_FILE)

clean: ## Clean up temporary files
	find . -name '*.retry' -delete
	find . -name '__pycache__' -type d -exec rm -rf {} + 2>/dev/null || true
