#!/bin/bash

# ==============================================
# Скрипт установки Git GitFlow Plugin v2.0
# ==============================================

set -e

# Цвета для сообщений
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Функции для вывода сообщений
info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

success() {
    echo -e "${GREEN}✔ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

error() {
    echo -e "${RED}✗ $1${NC}" >&2
}

section() {
    echo -e "\n${CYAN}=== $1 ===${NC}"
}

# Проверка наличия git
check_git() {
    if ! command -v git &> /dev/null; then
        error "Git не установлен"
        exit 1
    fi
    success "Git найден: $(git --version)"
}

# Проверка наличия основного скрипта
check_script() {
    if [[ ! -f "git-gitflow" ]]; then
        error "Файл git-gitflow не найден в текущей директории"
        exit 1
    fi
    success "Скрипт git-gitflow найден"
}

# Определение директории установки
get_install_dir() {
    # Проверяем доступные директории в PATH
    local path_dirs=($(echo "$PATH" | tr ':' '\n'))
    local install_dir=""
    
    # Предпочтительные директории
    local preferred_dirs=(
        "/usr/local/bin"
        "$HOME/.local/bin"
        "$HOME/bin"
    )
    
    for dir in "${preferred_dirs[@]}"; do
        if [[ " ${path_dirs[@]} " =~ " $dir " ]]; then
            if [[ -d "$dir" ]] && [[ -w "$dir" ]]; then
                install_dir="$dir"
                break
            elif [[ "$dir" == "$HOME/.local/bin" ]] || [[ "$dir" == "$HOME/bin" ]]; then
                # Создаем директорию пользователя если её нет
                mkdir -p "$dir"
                install_dir="$dir"
                break
            fi
        fi
    done
    
    # Если не найдена подходящая директория, используем /usr/local/bin
    if [[ -z "$install_dir" ]]; then
        install_dir="/usr/local/bin"
    fi
    
    echo "$install_dir"
}

# Установка скрипта
install_script() {
    local install_dir="$1"
    local target_file="$install_dir/git-gitflow"
    
    info "Установка в: $install_dir"
    
    # Проверяем права доступа
    if [[ ! -w "$install_dir" ]]; then
        info "Требуются права администратора для записи в $install_dir"
        if command -v sudo &> /dev/null; then
            sudo cp git-gitflow "$target_file"
            sudo chmod +x "$target_file"
        else
            error "Нет прав для записи в $install_dir и sudo недоступен"
            exit 1
        fi
    else
        cp git-gitflow "$target_file"
        chmod +x "$target_file"
    fi
    
    success "Скрипт установлен: $target_file"
}

# Проверка установки
verify_installation() {
    if command -v git-gitflow &> /dev/null; then
        success "Установка успешна!"
        info "Теперь вы можете использовать: git gitflow"
    else
        warning "Команда git-gitflow не найдена в PATH"
        info "Возможно потребуется перезапустить терминал или выполнить:"
        echo "  export PATH=\$PATH:$install_dir"
    fi
}

# Создание алиаса (опционально)
create_alias() {
    local shell_rc=""
    
    # Определяем файл конфигурации shell
    if [[ -n "$BASH_VERSION" ]]; then
        shell_rc="$HOME/.bashrc"
    elif [[ -n "$ZSH_VERSION" ]]; then
        shell_rc="$HOME/.zshrc"
    else
        shell_rc="$HOME/.profile"
    fi
    
    echo ""
    read -p "Создать алиас 'gf' для 'git gitflow'? (y/n) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [[ -f "$shell_rc" ]]; then
            if ! grep -q "alias gf=" "$shell_rc"; then
                echo "alias gf='git gitflow'" >> "$shell_rc"
                success "Алиас добавлен в $shell_rc"
                info "Перезапустите терминал или выполните: source $shell_rc"
            else
                info "Алиас уже существует в $shell_rc"
            fi
        else
            warning "Файл $shell_rc не найден"
        fi
    fi
}

# Показать информацию об использовании
show_usage_info() {
    section "ИСПОЛЬЗОВАНИЕ"
    echo -e "${YELLOW}Основные команды:${NC}"
    echo "  git gitflow                    # Интерактивное меню"
    echo "  git gitflow deliver            # Доведение в test"
    echo "  git gitflow deliver release_oe # Доведение в release_oe"
    echo "  git gitflow hotfix pe TASK-123 # Создание hotfix"
    echo "  git gitflow status             # Показать статус"
    echo "  git gitflow help               # Справка"
    echo ""
    echo -e "${YELLOW}Документация:${NC}"
    echo "  Подробная документация доступна в README.md"
    echo ""
    echo -e "${GREEN}Установка завершена успешно!${NC}"
}

# Основная функция
main() {
    section "УСТАНОВКА GIT GITFLOW PLUGIN V2.0"
    
    # Проверки
    check_git
    check_script
    
    # Определение директории установки
    local install_dir=$(get_install_dir)
    
    # Установка
    section "УСТАНОВКА"
    install_script "$install_dir"
    
    # Проверка
    section "ПРОВЕРКА"
    verify_installation
    
    # Создание алиаса
    create_alias
    
    # Информация об использовании
    show_usage_info
}

# Обработка аргументов
case "${1:-}" in
    "--help"|"-h")
        echo "Скрипт установки Git GitFlow Plugin v2.0"
        echo ""
        echo "Использование: $0 [опции]"
        echo ""
        echo "Опции:"
        echo "  --help, -h     Показать эту справку"
        echo "  --uninstall    Удалить плагин"
        echo ""
        exit 0
        ;;
    "--uninstall")
        section "УДАЛЕНИЕ GIT GITFLOW PLUGIN"
        
        # Поиск установленного скрипта
        local script_path=$(command -v git-gitflow 2>/dev/null || true)
        
        if [[ -n "$script_path" ]]; then
            info "Найден установленный скрипт: $script_path"
            
            if [[ -w "$(dirname "$script_path")" ]]; then
                rm "$script_path"
            else
                sudo rm "$script_path"
            fi
            
            success "Плагин удален"
        else
            warning "Установленный плагин не найден"
        fi
        
        # Удаление алиаса
        local shell_rc=""
        if [[ -n "$BASH_VERSION" ]]; then
            shell_rc="$HOME/.bashrc"
        elif [[ -n "$ZSH_VERSION" ]]; then
            shell_rc="$HOME/.zshrc"
        else
            shell_rc="$HOME/.profile"
        fi
        
        if [[ -f "$shell_rc" ]] && grep -q "alias gf=" "$shell_rc"; then
            read -p "Удалить алиас 'gf' из $shell_rc? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sed -i '/alias gf=/d' "$shell_rc"
                success "Алиас удален из $shell_rc"
            fi
        fi
        
        success "Удаление завершено"
        exit 0
        ;;
    "")
        main
        ;;
    *)
        error "Неизвестная опция: $1"
        echo "Используйте --help для справки"
        exit 1
        ;;
esac