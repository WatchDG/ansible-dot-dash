# Ansible Vault - Инструкции по использованию

## Обзор

В этом проекте настроен Ansible Vault для безопасного хранения конфиденциальных данных, таких как пароли и API ключи.

## Структура файлов

- `group_vars/docker-vault.yml` - зашифрованный файл с конфиденциальными переменными
- `.vault_pass` - файл с паролем для vault (опционально)
- `ansible.cfg` - настроен для автоматического использования пароля из файла

## Переменные в vault

В файле `group_vars/docker-vault.yml` хранятся:
- `docker_password` - пароль для Docker репозитория

## Команды для работы с vault

### Просмотр содержимого vault
```bash
wsl ansible-vault view group_vars/docker-vault.yml
```

### Редактирование vault
```bash
wsl ansible-vault edit group_vars/docker-vault.yml
```

### Изменение пароля vault
```bash
wsl ansible-vault rekey group_vars/docker-vault.yml
```

### Шифрование нового файла
```bash
wsl ansible-vault encrypt filename.yml
```

### Расшифровка файла
```bash
wsl ansible-vault decrypt filename.yml
```

## Запуск playbook с vault

### С запросом пароля
```bash
wsl ansible-playbook --ask-vault-pass playbooks/docker-login.yml
```

### С использованием файла пароля
```bash
wsl ansible-playbook --vault-password-file .vault_pass playbooks/docker-login.yml
```

### Автоматическое использование пароля из ansible.cfg
```bash
wsl ansible-playbook playbooks/docker-login.yml
```

## Безопасность

⚠️ **Важно:**
- Никогда не коммитьте файл `.vault_pass` в git
- Добавьте `.vault_pass` в `.gitignore`
- Используйте сильные пароли для vault
- Регулярно меняйте пароли vault

## Добавление новых переменных в vault

1. Откройте vault для редактирования:
   ```bash
   wsl ansible-vault edit group_vars/docker-vault.yml
   ```

2. Добавьте новые переменные в формате YAML:
   ```yaml
   ---
   # Существующие переменные
   docker_password: "your_password_here"
   
   # Новые переменные
   new_secret: "new_secret_value"
   api_key: "your_api_key_here"
   ```

3. Сохраните файл (в vim: `:wq`)

## Использование переменных из vault в playbook

Переменные из vault автоматически доступны в playbook, если vault файл подключен в `vars_files`:

```yaml
vars_files:
  - "../group_vars/docker-vault.yml"
```

Затем используйте переменные как обычно:
```yaml
- name: "Пример использования переменной из vault"
  debug:
    msg: "Пароль: {{ docker_password }}"
```
