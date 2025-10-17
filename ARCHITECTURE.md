# 🏗️ Архитектура GitFlow Automation Tool

## Обзор структуры

Плагин состоит из модульных скриптов, которые работают вместе для автоматизации GitFlow процессов.

```
git-flow-common           # Общие функции и константы
    ↑
    ├── git-flow          # Главное интерактивное меню
    ├── git-flow-deliver  # Автоматизация delivery
    ├── git-flow-hotfix   # Работа с hotfix
    └── git-flow-continue # Продолжение после конфликтов
```

---

## Файлы проекта

### Исполняемые скрипты

| Файл | Размер | Назначение |
|------|--------|-----------|
| `git-flow` | ~9KB | Главное интерактивное меню |
| `git-flow-common` | ~9KB | Библиотека общих функций |
| `git-flow-deliver` | ~8KB | Автоматизация доставки изменений |
| `git-flow-hotfix` | ~6KB | Создание и работа с hotfix |
| `git-flow-continue` | ~11KB | Продолжение прерванных операций |
| `install.sh` | ~2KB | Скрипт установки |

### Документация

| Файл | Назначение |
|------|-----------|
| `README.md` | Полная документация |
| `QUICKSTART.md` | Быстрый старт |
| `EXAMPLES.md` | Подробные примеры использования |
| `ARCHITECTURE.md` | Архитектура (этот файл) |

---

## git-flow-common - Общая библиотека

### Константы

```bash
# Цвета для вывода
RED, GREEN, YELLOW, BLUE, CYAN, MAGENTA, NC

# Файл состояния
STATE_FILE=".git/git-flow-state"
```

### Функции отображения

- `section(text)` - Заголовок секции
- `error(text)` - Сообщение об ошибке
- `warning(text)` - Предупреждение
- `success(text)` - Успех
- `info(text)` - Информация

### Функции проверки

- `filter_changes()` - Получить список изменений
- `check_changes()` - Проверить и спросить о продолжении
- `check_conflicts()` - Проверить наличие конфликтов
- `show_conflict_status()` - Показать статус конфликтов

### Функции парсинга

- `parse_feature_branch(branch)` - Разобрать feature ветку
  - Извлекает PARENT_JIRA и JIRA
  - Обрабатывает служебные префиксы (stable_, test_, etc)
  
- `parse_hotfix_branch(branch)` - Разобрать hotfix ветку
  - Извлекает HOTFIX_TYPE и JIRA

### Функции работы с ветками

- `get_branch_names()` - Генерирует имена всех служебных веток
- `create_or_update_branch(name, base)` - Создает или обновляет ветку
- `safe_push(branch, force)` - Безопасная отправка с опцией force-with-lease

### Функции работы с коммитами

- `select_commits(branch)` - Интерактивный выбор коммитов
  - Показывает коммиты от базовой ветки
  - Фильтрует merge-коммиты
  - Поддерживает выбор количества или "all"

### Функции состояния

- `save_state(operation, branch, commits...)` - Сохранить состояние
- `load_state()` - Загрузить состояние
- `clear_state()` - Очистить состояние

### Утилиты

- `show_summary(pr_branch)` - Финальный вывод результатов

---

## git-flow - Главное меню

### Структура

```bash
main()
  └── show_menu()
      ├── Определение доступных действий
      ├── Отображение меню
      └── execute_action(action)
          ├── deliver → git-flow-deliver
          ├── hotfix-push → git-flow-hotfix push
          ├── continue → git-flow-continue
          ├── new-delivery → create_feature_branch()
          ├── new-hotfix → git-flow-hotfix create
          ├── status → show_status()
          ├── help → show_help()
          └── exit
```

### Логика определения доступных действий

```bash
if parse_feature_branch(current_branch):
    available_actions += "deliver"

if parse_hotfix_branch(current_branch):
    available_actions += "hotfix-push"

if exists(STATE_FILE):
    available_actions += "continue"

# Всегда доступны:
available_actions += ["new-delivery", "new-hotfix", "status", "help", "exit"]
```

---

## git-flow-deliver - Доставка изменений

### Алгоритм работы

```
1. check_changes()
   └── Проверка незакоммиченных изменений

2. parse_feature_branch(current_branch)
   └── Извлечение PARENT_JIRA и JIRA

3. select_commits(current_branch)
   ├── Показать коммиты от master
   ├── Запросить количество
   └── Отфильтровать merge-коммиты

4. select_target_environment()
   └── Выбор: test / release_oe / release_pe

5. process_stable_branch()
   ├── create_or_update_branch(stable, master)
   ├── Cherry-pick коммитов
   │   ├── При конфликте: save_state() → exit
   │   └── После всех: squash_commits()
   └── safe_push(stable)

6. process_merge_branch()
   ├── create_or_update_branch(merge, target_env)
   ├── Проверка существующего PR
   │   ├── Вариант 1: Пересоздать ветку
   │   └── Вариант 2: Добавить изменения
   ├── Merge stable → merge_branch
   │   └── При конфликте: save_state() → exit
   └── safe_push(merge_branch, force?)

7. Возврат на исходную ветку
8. clear_state()
9. show_summary()
```

### Ключевые функции

**process_stable_branch()**
- Создает/обновляет stable ветку
- Выполняет cherry-pick с обработкой конфликтов
- Предлагает squash
- Отправляет в репозиторий

**process_merge_branch()**
- Создает/обновляет merge ветку
- Обрабатывает обновление существующего PR
- Выполняет merge с обработкой конфликтов
- Отправляет с force-with-lease при обновлении PR

**squash_commits()**
- Находит базовый коммит (merge-base с master)
- Считает количество коммитов
- Выполняет soft reset + commit

---

## git-flow-hotfix - Работа с hotfix

### Команды

- `create` - Создание новой hotfix ветки
- `push` - Отправка существующей hotfix ветки

### Алгоритм create

```
1. Выбор типа: pe / oe / iz
2. Ввод версии (XX.XX.XX.X)
3. Проверка существования versions/{type}/{version}
4. Ввод JIRA
5. Создание hotfixes/{type}/{JIRA} от versions/{type}/{version}
6. Выбор источника: test / release_oe / release_pe
7. Показ коммитов из источника
8. Ввод хеша коммита
9. Cherry-pick коммита
   └── При конфликте: save_state() → exit
10. safe_push()
```

### Алгоритм push

```
1. parse_hotfix_branch(current_branch)
2. Проверка незакоммиченных изменений
   └── Опция закоммитить
3. safe_push()
```

---

## git-flow-continue - Продолжение операций

### Поддерживаемые операции

| Операция | Что продолжает |
|----------|---------------|
| `stable-cherry-pick` | Cherry-pick в stable ветку |
| `merge-to-test` | Merge в test ветку |
| `merge-to-release_oe` | Merge в release_oe ветку |
| `merge-to-release_pe` | Merge в release_pe ветку |
| `hotfix-cherry-pick` | Cherry-pick в hotfix ветку |

### Алгоритм работы

```
1. load_state()
   └── Загрузка операции из .git/git-flow-state

2. Проверка типа операции
   ├── stable-cherry-pick → continue_stable_cherry_pick()
   ├── merge-to-* → continue_merge_to_env()
   └── hotfix-cherry-pick → continue_hotfix_cherry_pick()
```

### continue_stable_cherry_pick()

```
1. check_conflicts() → ошибка если есть
2. Проверка staged изменений
3. git cherry-pick --continue
4. Если остались коммиты:
   ├── Cherry-pick остальных
   └── При конфликте: save_state() → exit
5. squash_commits() (опционально)
6. safe_push(stable)
7. proceed_to_merge_branch()
   └── Автоматически продолжает создание merge ветки
```

### continue_merge_to_env()

```
1. check_conflicts() → ошибка если есть
2. Проверка staged изменений
3. git commit --no-edit
4. safe_push(merge_branch, force?)
5. Возврат на исходную ветку
6. clear_state()
7. show_summary()
```

---

## Управление состоянием

### Файл состояния: `.git/git-flow-state`

Формат:
```bash
OPERATION=stable-cherry-pick
ORIGINAL_BRANCH=tasks/PROJ-123/TASK-456
PARENT_JIRA=PROJ-123
JIRA=TASK-456
TARGET_ENV=test
COMMITS=abc123 def456 ghi789
```

### Жизненный цикл состояния

```
git-flow-deliver
  ↓
При конфликте: save_state()
  ↓
[.git/git-flow-state создан]
  ↓
Пользователь разрешает конфликт
  ↓
git flow continue
  ↓
load_state() → выполнение → clear_state()
  ↓
[.git/git-flow-state удален]
```

---

## Обработка ошибок

### Уровни обработки

1. **Проверки перед выполнением**
   - Незакоммиченные изменения
   - Формат ветки
   - Существование веток

2. **Обработка конфликтов**
   - Сохранение состояния
   - Информативные сообщения
   - Инструкции по продолжению

3. **Валидация входных данных**
   - Формат версии для hotfix
   - Существование коммитов
   - Корректность выбора

---

## Расширение плагина

### Добавление новой команды

1. Создайте новый скрипт `git-flow-{command}`
2. Подключите `git-flow-common`
3. Используйте общие функции
4. Добавьте в меню `git-flow`:

```bash
# В show_menu()
if [условие]; then
    available_actions+=("new-command")
fi

# В execute_action()
case $action in
    new-command)
        "$SCRIPT_DIR/git-flow-{command}"
        ;;
esac
```

### Пример: Добавление команды для cleanup

```bash
# Создать файл: git-flow-cleanup
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/git-flow-common"

section "ОЧИСТКА ЛОКАЛЬНЫХ ВЕТОК"

# Получить список merged веток
merged_branches=$(git branch --merged master | grep -v "^\*" | grep -v "master")

if [[ -z "$merged_branches" ]]; then
    success "Нет веток для очистки"
    exit 0
fi

echo "Следующие ветки будут удалены:"
echo "$merged_branches"

read -p "Продолжить? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "$merged_branches" | xargs git branch -d
    success "Ветки удалены"
fi
```

### Добавление новых функций в git-flow-common

```bash
# Добавить функцию
my_new_function() {
    # код
}

# Экспортировать
export -f my_new_function
```

---

## Тестирование

### Ручное тестирование

```bash
# 1. Создать тестовый репозиторий
mkdir test-repo && cd test-repo
git init

# 2. Создать базовые ветки
git commit --allow-empty -m "Initial"
git branch master
git branch test
git branch release_oe
git branch release_pe

# 3. Создать feature ветку
git checkout -b tasks/TEST-1/TASK-1 test

# 4. Сделать коммиты
echo "feature" > file.txt
git add file.txt
git commit -m "Add feature"

# 5. Тестировать плагин
git flow deliver
```

### Проверка конфликтов

```bash
# 1. Создать изменение в master
git checkout master
echo "master change" > file.txt
git add file.txt
git commit -m "Master change"

# 2. Создать конфликтующее изменение в feature
git checkout tasks/TEST-1/TASK-1
echo "feature change" > file.txt
git add file.txt
git commit -m "Feature change"

# 3. Тестировать delivery с конфликтом
git flow deliver
# Должен возникнуть конфликт → разрешить → continue
```

---

## Производительность

### Оптимизации

1. **Минимизация обращений к удаленному репозиторию**
   - Fetch только при необходимости
   - Проверка существования удаленных веток

2. **Эффективная работа с git**
   - Использование `--no-ff` для merge
   - `--force-with-lease` вместо `--force`

3. **Кэширование результатов**
   - Сохранение состояния в файл
   - Переиспользование parsed данных

---

## Безопасность

### Меры безопасности

1. **Force-with-lease вместо force**
   - Защита от перезаписи чужих изменений
   
2. **Проверка конфликтов**
   - Запрет продолжения с неразрешенными конфликтами

3. **Валидация входных данных**
   - Проверка форматов
   - Проверка существования веток/коммитов

4. **Сохранение состояния**
   - Возможность восстановления после ошибки

---

## Зависимости

### Системные требования

- **Git** >= 2.0
- **Bash** >= 4.0
- **Стандартные утилиты**: grep, sed, awk, tac

### Опциональные зависимости

- `gh` (GitHub CLI) - для автоматического создания PR (будущая функция)
- `jq` - для работы с JSON (будущая функция)

---

## Будущие улучшения

### Планируемые функции

1. **Автоматическое создание PR**
   ```bash
   # Интеграция с gh
   gh pr create --base test --head $MERGE_BRANCH
   ```

2. **Поддержка нескольких версий GitFlow**
   ```bash
   # Конфигурационный файл .gitflow-config
   MAIN_BRANCH=main
   DEV_BRANCH=develop
   ```

3. **Статистика и отчеты**
   ```bash
   git flow stats
   # Показать сколько PR создано, время доставки и т.д.
   ```

4. **Интерактивный выбор коммитов**
   ```bash
   # Чекбоксы для выбора конкретных коммитов
   [x] abc123 Feature A
   [ ] def456 Feature B (merge)
   [x] ghi789 Feature C
   ```

5. **Поддержка pre/post hooks**
   ```bash
   # .git/hooks/git-flow-pre-deliver
   # .git/hooks/git-flow-post-deliver
   ```

---

## Вклад в разработку

### Структура коммитов

```
[component] Краткое описание

Подробное описание изменений
```

Примеры:
```
[deliver] Добавлена поддержка фильтрации merge-коммитов
[common] Улучшена обработка ошибок
[docs] Обновлены примеры использования
```

### Стиль кода

- Отступы: 4 пробела
- Функции: `snake_case`
- Константы: `UPPER_CASE`
- Комментарии на русском языке
- Обязательные заголовки файлов

---

**Документация актуальна для версии 2.0**
