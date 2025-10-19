# 🚀 Быстрый старт

## Установка

```bash
./install.sh
```

Перезапустите терминал или выполните:
```bash
source ~/.bashrc
```

## Основные команды

### 📋 Интерактивное меню
```bash
git flow
```

### 🚀 Доставка изменений
```bash
# Из feature ветки tasks/PARENT_JIRA/JIRA
git flow deliver
```

**Шаги:**
1. Выберите количество коммитов (число или `all`)
2. Выберите окружение (1 - test, 2 - release_oe, 3 - release_pe)
3. Подтвердите squash (рекомендуется)
4. Готово! 🎉

### 🔧 Hotfix
```bash
git flow hotfix create
```

**Шаги:**
1. Выберите тип (1 - PE, 2 - OE, 3 - IZ)
2. Введите версию (XX.XX.XX.XX)
3. Введите JIRA
4. Выберите источник коммита
5. Введите хеш коммита
6. Готово! 🎉

### ↪️ Продолжение после конфликта
```bash
# 1. Разрешите конфликты
vim <файл>

# 2. Добавьте файлы
git add <файлы>

# 3. Продолжите
git flow continue
```

## Структура веток

### Feature
```
tasks/JIRA-123/JIRA-321              # Ваша ветка разработки
tasks/JIRA-123/stable_JIRA-321       # Автоматически создается
tasks/JIRA-123/test_JIRA-321         # Ветка для PR
```

### Hotfix
```
hotfixes/pe/JIRA-321                 # Hotfix для PE
hotfixes/oe/JIRA-321                 # Hotfix для OE
hotfixes/iz/JIRA-321                 # Hotfix для IZ
```

## Типичные сценарии

### Первая доставка
```bash
git flow deliver
> 3                    # 3 коммита
> 1                    # test
> Y                    # да, squash
```

### Доработка PR
```bash
git flow deliver
> 1                    # 1 коммит
> 1                    # test
> 1                    # обновить PR
```

### Срочная доставка в release_pe
```bash
git flow deliver
> all                  # все коммиты
> 3                    # release_pe
> Y                    # да, squash
```

## 💡 Советы

✅ Всегда используйте squash в stable ветке  
✅ Проверяйте список коммитов перед доставкой  
✅ При конфликтах внимательно проверяйте код  

📚 **Полная документация:** [README.md](README.md)
