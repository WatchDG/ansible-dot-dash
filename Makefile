# Makefile для управления Ansible проектом

.PHONY: help install check syntax test deploy clean

# Пути к конфигурации Ansible
ANSIBLE_CONFIG := $(PWD)/ansible.cfg
INVENTORY_FILE := $(PWD)/inventory/hosts.yml
PLAYBOOK_FILE := $(PWD)/playbook.yml

# Команды Ansible (попробуем разные варианты)
ANSIBLE_CMD := ansible
ANSIBLE_PLAYBOOK_CMD := ansible-playbook
ANSIBLE_GALAXY_CMD := ansible-galaxy
ANSIBLE_INVENTORY_CMD := ansible-inventory

# Проверяем доступность команд
ifeq ($(shell which ansible 2>/dev/null),)
    ANSIBLE_CMD := python3 -m ansible
    ANSIBLE_PLAYBOOK_CMD := python3 -m ansible.playbook
    ANSIBLE_GALAXY_CMD := python3 -m ansible.galaxy
    ANSIBLE_INVENTORY_CMD := python3 -m ansible.inventory
endif

# Цвета для вывода
GREEN=\033[0;32m
YELLOW=\033[1;33m
RED=\033[0;31m
NC=\033[0m # No Color

help: ## Показать справку
	@echo "$(GREEN)Доступные команды:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}'

install-ansible: ## Установить Ansible
	@echo "$(GREEN)Установка Ansible...$(NC)"
	pip install ansible

install: ## Установить зависимости из requirements.yml
	@echo "$(GREEN)Установка зависимостей...$(NC)"
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) $(ANSIBLE_GALAXY_CMD) install -r requirements.yml

check: ## Проверить синтаксис playbook'ов
	@echo "$(GREEN)Проверка синтаксиса...$(NC)"
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) $(ANSIBLE_PLAYBOOK_CMD) --syntax-check -i $(INVENTORY_FILE) $(PLAYBOOK_FILE)

syntax: check ## Алиас для check

test: ## Запустить playbook в режиме проверки (dry-run)
	@echo "$(GREEN)Запуск в режиме проверки...$(NC)"
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) $(ANSIBLE_PLAYBOOK_CMD) --check --diff -i $(INVENTORY_FILE) $(PLAYBOOK_FILE)

deploy: ## Запустить полное развертывание
	@echo "$(GREEN)Запуск развертывания...$(NC)"
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) $(ANSIBLE_PLAYBOOK_CMD) -i $(INVENTORY_FILE) $(PLAYBOOK_FILE)

deploy-vps: ## Развернуть только VPS серверы
	@echo "$(GREEN)Развертывание VPS серверов...$(NC)"
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) $(ANSIBLE_PLAYBOOK_CMD) -i $(INVENTORY_FILE) $(PLAYBOOK_FILE) --limit vps

deploy-docker: ## Установить Docker на хосты группы docker
	@echo "$(GREEN)Установка Docker...$(NC)"
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) $(ANSIBLE_PLAYBOOK_CMD) -i $(INVENTORY_FILE) playbooks/docker.yml

ping: ## Проверить подключение к хостам
	@echo "$(GREEN)Проверка подключения...$(NC)"
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) $(ANSIBLE_CMD) all -i $(INVENTORY_FILE) -m ping

inventory: ## Показать инвентарь
	@echo "$(GREEN)Инвентарь хостов:$(NC)"
	ANSIBLE_CONFIG=$(ANSIBLE_CONFIG) $(ANSIBLE_INVENTORY_CMD) -i $(INVENTORY_FILE) --list

clean: ## Очистить временные файлы
	@echo "$(GREEN)Очистка временных файлов...$(NC)"
	find . -name "*.retry" -delete
	find . -name "*.log" -delete

copy-ssh-key: ## Скопировать SSH ключ в стандартное место
	@echo "$(GREEN)Копирование SSH ключа...$(NC)"
	@echo "$(YELLOW)Выполните команду:$(NC)"
	@echo "cp /mnt/d/ssh/key ~/.ssh/id_ed25519 && chmod 600 ~/.ssh/id_ed25519"

copy-vault-pass: ## Скопировать SSH ключ в стандартное место
	@echo "$(GREEN)Копирование SSH ключа...$(NC)"
	@echo "$(YELLOW)Выполните команду:$(NC)"
	@echo "mkdir -p ~/.vault && cp .vault_pass ~/.vault/.vault_pass && chmod -x ~/.vault/.vault_pass"

# Команды для разработки
dev-setup: install check ## Настройка окружения для разработки
	@echo "$(GREEN)Окружение для разработки настроено!$(NC)"

# Команды для продакшена
prod-deploy: install check test deploy ## Полное развертывание в продакшен
	@echo "$(GREEN)Развертывание в продакшен завершено!$(NC)"
