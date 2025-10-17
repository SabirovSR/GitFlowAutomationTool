#!/bin/bash

# ==============================================
# Установщик Git Flow Helper
# ==============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     Git Flow Helper - Установка v2.0        ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""

# Проверяем права
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}Этот скрипт не должен запускаться от root!${NC}"
   exit 1
fi

# Определяем директорию установки
INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="git-flow-helper"
SOURCE_FILE="./git-flow-helper"

# Проверяем наличие исходного файла
if [[ ! -f "$SOURCE_FILE" ]]; then
    echo -e "${RED}Ошибка: Файл $SOURCE_FILE не найден!${NC}"
    exit 1
fi

# Создаем директорию если не существует
if [[ ! -d "$INSTALL_DIR" ]]; then
    echo -e "${YELLOW}Создание директории $INSTALL_DIR${NC}"
    mkdir -p "$INSTALL_DIR"
fi

# Копируем скрипт
echo -e "${CYAN}Установка скрипта в $INSTALL_DIR/$SCRIPT_NAME${NC}"
cp "$SOURCE_FILE" "$INSTALL_DIR/$SCRIPT_NAME"
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# Проверяем PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo -e "${YELLOW}Добавление $INSTALL_DIR в PATH${NC}"
    
    # Определяем какой shell используется
    SHELL_RC=""
    if [[ -n "$BASH_VERSION" ]]; then
        SHELL_RC="$HOME/.bashrc"
    elif [[ -n "$ZSH_VERSION" ]]; then
        SHELL_RC="$HOME/.zshrc"
    fi
    
    if [[ -n "$SHELL_RC" ]]; then
        echo "" >> "$SHELL_RC"
        echo "# Git Flow Helper" >> "$SHELL_RC"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$SHELL_RC"
        echo -e "${GREEN}✓ PATH обновлен в $SHELL_RC${NC}"
        echo -e "${YELLOW}Выполните: source $SHELL_RC${NC}"
    fi
fi

# Создаем алиасы для git
echo ""
echo -e "${CYAN}Хотите создать git алиасы для быстрого доступа? (y/n)${NC}"
read -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    git config --global alias.flow '!git-flow-helper'
    git config --global alias.deliver '!git-flow-helper deliver'
    git config --global alias.hotfix '!git-flow-helper hotfix'
    git config --global alias.flow-continue '!git-flow-helper continue'
    git config --global alias.flow-status '!git-flow-helper status'
    
    echo -e "${GREEN}✓ Git алиасы созданы:${NC}"
    echo "  - git flow          (интерактивное меню)"
    echo "  - git deliver       (быстрая доставка)"
    echo "  - git hotfix        (создание hotfix)"
    echo "  - git flow-continue (продолжение после конфликтов)"
    echo "  - git flow-status   (анализ состояния)"
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        Установка успешно завершена!         ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Использование:${NC}"
echo "  git-flow-helper     - запустить интерактивное меню"
echo "  git flow            - через git алиас (если установлен)"
echo ""
echo -e "${YELLOW}Не забудьте выполнить: source ~/.bashrc (или ~/.zshrc)${NC}"