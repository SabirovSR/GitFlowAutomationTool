#!/bin/bash

# ==============================================
# install.sh - установка GitFlow плагина
# Автор: Сабиров Савелий Русланович
# Версия: 2.0
# ==============================================

CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}      Установка GitFlow Automation Tool v2.0          ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Определяем директорию установки
INSTALL_DIR="$HOME/.local/bin"

# Создаем директорию если не существует
if [[ ! -d "$INSTALL_DIR" ]]; then
    echo "Создание директории $INSTALL_DIR..."
    mkdir -p "$INSTALL_DIR"
fi

# Проверяем, что директория в PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo -e "${RED}ВНИМАНИЕ: $INSTALL_DIR не в PATH${NC}"
    echo "Добавьте следующую строку в ~/.bashrc или ~/.bash_profile:"
    echo ""
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
    read -p "Добавить автоматически в ~/.bashrc? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "" >> ~/.bashrc
        echo "# GitFlow Automation Tool" >> ~/.bashrc
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> ~/.bashrc
        echo -e "${GREEN}✔ Добавлено в ~/.bashrc${NC}"
        echo "Перезапустите терминал или выполните: source ~/.bashrc"
    fi
fi

# Копируем скрипты
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Копирование файлов в $INSTALL_DIR..."

for script in git-flow git-flow-common git-flow-deliver git-flow-hotfix git-flow-continue; do
    if [[ -f "$SCRIPT_DIR/$script" ]]; then
        cp "$SCRIPT_DIR/$script" "$INSTALL_DIR/"
        chmod +x "$INSTALL_DIR/$script"
        echo -e "  ${GREEN}✔${NC} $script"
    else
        echo -e "  ${RED}✗${NC} $script (не найден)"
    fi
done

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}           Установка завершена успешно!                ${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Доступные команды:"
echo "  git flow          - интерактивное меню"
echo "  git flow deliver  - доставка изменений"
echo "  git flow hotfix   - работа с hotfix"
echo "  git flow continue - продолжение после конфликтов"
echo "  git flow help     - справка"
echo ""
echo "Документация: README.md"
