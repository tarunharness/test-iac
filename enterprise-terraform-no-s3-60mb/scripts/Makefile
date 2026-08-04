SHELL := /bin/bash
ENV ?= prod
ENV_DIR := environments/$(ENV)

.PHONY: help init fmt validate plan plan-json size show clean fmt-check lint

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-14s\033[0m %s\n", $$1, $$2}'

init: ## terraform init for ENV (default: prod)
	cd $(ENV_DIR) && terraform init

fmt: ## Rewrite all config to canonical format
	terraform fmt -recursive

fmt-check: ## Check formatting without writing
	terraform fmt -recursive -check

validate: ## Validate ENV configuration
	cd $(ENV_DIR) && terraform validate

plan: ## Generate a binary plan for ENV
	cd $(ENV_DIR) && terraform plan -out=tfplan.bin

plan-json: plan ## Generate plan and emit machine-readable plan.json
	cd $(ENV_DIR) && terraform show -json tfplan.bin > plan.json
	cd $(ENV_DIR) && terraform show -no-color tfplan.bin > plan.txt

size: plan-json ## Print the size of the generated plan artifacts
	@echo "==> Plan artifact sizes for ENV=$(ENV)"
	@ls -lh $(ENV_DIR)/tfplan.bin $(ENV_DIR)/plan.json $(ENV_DIR)/plan.txt
	@echo "==> Resource change count:"
	@cd $(ENV_DIR) && python3 -c "import json;print(len(json.load(open('plan.json'))['resource_changes']))"

clean: ## Remove local plan/state artifacts
	find . -type f \( -name 'tfplan.bin' -o -name 'plan.json' -o -name 'plan.txt' -o -name 'planlog.txt' \) -delete
	find . -type d -name '.terraform' -exec rm -rf {} +
