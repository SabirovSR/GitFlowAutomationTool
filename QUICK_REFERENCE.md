# Git Flow Helper - Краткая справка

## 🚀 Быстрые команды

### Основные операции

```bash
# Интерактивное меню
git-flow-helper
git flow                    # через алиас

# Быстрая доставка из feature ветки
git-flow-helper deliver
git deliver                 # через алиас

# Создание hotfix
git-flow-helper hotfix
git hotfix                  # через алиас

# Продолжение после конфликта
git-flow-helper continue
git flow-continue          # через алиас

# Анализ состояния
git-flow-helper status
git flow-status            # через алиас
```

### Работа с feature веткой

```bash
# Находясь в ветке tasks/PARENT/JIRA

# Доставить последний коммит в test
git-flow-helper deliver
> Выберите целевую ветку: 1 (test)
> Выберите коммиты: last

# Доставить несколько коммитов
git-flow-helper deliver
> Выберите коммиты: 1 2 3

# Доставить диапазон коммитов
git-flow-helper deliver
> Выберите коммиты: 1-5

# Обновить существующий PR
git-flow-helper
> Выберите действие: 2
```

### Работа с HotFix

```bash
# Создать hotfix для PE версии
git-flow-helper hotfix
> Выберите тип: 1 (PE)
> Выберите версию: 2
> Введите JIRA: PROJ-105
> Откуда взять коммиты: 3 (release_pe)
> Выберите коммиты: 1
```

### Разрешение конфликтов

```bash
# При конфликте cherry-pick
# 1. Исправьте конфликты в файлах
# 2. Добавьте файлы
git add .
# 3. Продолжите
git-flow-helper continue

# При конфликте merge
# 1. Исправьте конфликты
# 2. Добавьте и закоммитьте
git add .
git commit
# 3. Продолжите
git-flow-helper continue
```

## 📋 Структура веток

### Feature Flow
```
test → tasks/PARENT/JIRA (разработка)
       ↓ cherry-pick
       tasks/PARENT/stable_JIRA (от master)
       ↓ merge
       tasks/PARENT/test_JIRA → test (PR)
```

### HotFix Flow
```
test/release_* → hotfixes/TYPE/JIRA
                 ↓ cherry-pick
                 versions/TYPE/X.X.X.X (PR)
```

## 🎯 Выбор коммитов

| Команда | Описание |
|---------|----------|
| `last` | Последний коммит |
| `all` | Все коммиты (без merge) |
| `1 2 3` | Конкретные номера |
| `1-5` | Диапазон |

## ⚙️ Целевые ветки

| Номер | Ветка | Описание |
|-------|-------|----------|
| 1 | test | Обычная разработка (по умолчанию) |
| 2 | release_oe | Опытная эксплуатация |
| 3 | release_pe | Промышленная эксплуатация |

## 🔥 HotFix типы

| Тип | Префикс | Версионная ветка |
|-----|---------|------------------|
| PE | hotfixes/pe/ | versions/pe/X.X.X.X |
| OE | hotfixes/oe/ | versions/oe/X.X.X.X |
| IZ | hotfixes/iz/ | versions/iz/X.X.X.X |

## 💡 Полезные советы

1. **Всегда проверяйте состояние перед началом:**
   ```bash
   git-flow-helper status
   ```

2. **При конфликтах не паникуйте:**
   - Скрипт сохраняет состояние
   - Можно продолжить с `--continue`
   - Можно начать заново, удалив `.git-flow-helper-state`

3. **Для обновления PR:**
   - Не нужно удалять старый PR
   - Используйте опцию "Обновить существующий PR"
   - Изменения добавятся force push

4. **Squash коммитов:**
   - Скрипт предложит объединить коммиты в stable ветке
   - Это опционально, но рекомендуется для чистой истории

5. **Исключение merge коммитов:**
   - Автоматически исключаются при выборе
   - Показываются только реальные коммиты с изменениями

## 📊 Состояния доставки

| Файл | Описание |
|------|----------|
| `.git-flow-helper-state` | Временное состояние текущей доставки |
| `~/.git-flow-helper.conf` | Глобальная конфигурация (планируется) |

## 🆘 Экстренные команды

```bash
# Отменить текущую операцию
rm .git-flow-helper-state

# Вернуться на исходную ветку
git checkout tasks/PARENT/JIRA

# Удалить неудачную ветку
git branch -D branch_name

# Сбросить незавершенный cherry-pick
git cherry-pick --abort

# Сбросить незавершенный merge
git merge --abort
```