#!/bin/bash

# ==============================================
# test-install.sh - проверка корректности установки
# ==============================================

echo "🔍 Проверка установки GitFlow Automation Tool v2.0"
echo ""

# Цвета
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

passed=0
failed=0

# Функция проверки
check() {
    local name=$1
    local command=$2
    
    echo -n "  Проверка $name... "
    
    if eval "$command" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        ((passed++))
        return 0
    else
        echo -e "${RED}✗${NC}"
        ((failed++))
        return 1
    fi
}

echo "1. Проверка файлов:"
check "git-flow" "[ -f ./git-flow ] && [ -x ./git-flow ]"
check "git-flow-common" "[ -f ./git-flow-common ] && [ -x ./git-flow-common ]"
check "git-flow-deliver" "[ -f ./git-flow-deliver ] && [ -x ./git-flow-deliver ]"
check "git-flow-hotfix" "[ -f ./git-flow-hotfix ] && [ -x ./git-flow-hotfix ]"
check "git-flow-continue" "[ -f ./git-flow-continue ] && [ -x ./git-flow-continue ]"
check "install.sh" "[ -f ./install.sh ] && [ -x ./install.sh ]"

echo ""
echo "2. Проверка синтаксиса:"
check "git-flow" "bash -n ./git-flow"
check "git-flow-common" "bash -n ./git-flow-common"
check "git-flow-deliver" "bash -n ./git-flow-deliver"
check "git-flow-hotfix" "bash -n ./git-flow-hotfix"
check "git-flow-continue" "bash -n ./git-flow-continue"
check "install.sh" "bash -n ./install.sh"

echo ""
echo "3. Проверка документации:"
check "README.md" "[ -f ./README.md ]"
check "QUICKSTART.md" "[ -f ./QUICKSTART.md ]"
check "EXAMPLES.md" "[ -f ./EXAMPLES.md ]"
check "START_HERE.md" "[ -f ./START_HERE.md ]"
check "ARCHITECTURE.md" "[ -f ./ARCHITECTURE.md ]"

echo ""
echo "4. Проверка размеров:"
check "git-flow не пустой" "[ -s ./git-flow ]"
check "README.md не пустой" "[ -s ./README.md ]"

echo ""
echo "════════════════════════════════════════"
echo "Результаты:"
echo -e "  ${GREEN}Пройдено: $passed${NC}"
echo -e "  ${RED}Провалено: $failed${NC}"
echo "════════════════════════════════════════"

if [ $failed -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ ВСЕ ПРОВЕРКИ ПРОЙДЕНЫ!${NC}"
    echo ""
    echo "Следующие шаги:"
    echo "  1. Запустите: ./install.sh"
    echo "  2. Перезапустите терминал"
    echo "  3. Проверьте: git flow help"
    echo ""
    exit 0
else
    echo ""
    echo -e "${RED}❌ ОБНАРУЖЕНЫ ПРОБЛЕМЫ${NC}"
    echo "Проверьте файлы и повторите попытку"
    echo ""
    exit 1
fi
