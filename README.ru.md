# Mango Layouts

Плагин для [Noctalia](https://noctalia.dev) v5, который позволяет переключать схемы тайлинга (layout) [MangoWM](https://mangowm.github.io) прямо из панели, с визуальными превью и двусторонней синхронизацией через `mmsg`.

## Возможности

- **Виджет в баре** — показывает название и иконку текущего layout, циклически переключает по клику
- **Панель превью** — 15 схем тайлинга с визуальными миниатюрами (Tile, Scroller, Grid, Monocle, Deck, Center Tile и др.)
- **Пульсирующая анимация** — активная карточка мягко пульсирует, сразу видно текущий режим
- **Двусторонняя синхронизация** — плагин слушает `mmsg -w` и опрашивает `mmsg -g -l`; смена layout с клавиатуры мгновенно обновляет виджет
- **Кнопка в Control Center** — быстрый доступ к панели
- **Чистый Luau** — без QML/Quickshell, работает в рантайме Noctalia v5

## Требования

| Зависимость | Назначение |
|---|---|
| [Noctalia](https://noctalia.dev) v5.0.0+ | Хост плагинов |
| [MangoWM](https://mangowm.github.io) | Wayland-композитор |
| `mmsg` | IPC-утилита (поставляется с MangoWM) |

## Установка

```bash
# Через менеджер плагинов (рекомендуется)
noctalia plugin add Collalaoo/mango-layouts

# Или вручную:
git clone https://github.com/Collalaoo/mango-layouts.git
mkdir -p ~/.local/share/noctalia/plugins/Collalaoo
cp -r mango-layouts ~/.local/share/noctalia/plugins/Collalaoo/
noctalia msg plugins reload
noctalia msg plugins enable Collalaoo/mango-layouts
```

Добавьте виджет в бар:

```toml
# ~/.config/noctalia/config.toml
[bar.main]
end = ["...", "switcher"]
```

Ярлык в Control Center добавляется через **Settings → Control Center → Shortcuts**.

## Использование

| Действие | Результат |
|---|---|
| **Левый клик** по виджету | Следующий layout (или открыть панель — настраивается) |
| **Правый клик** по виджету | Открыть панель Layout Switcher |
| **Клик по карточке** в панели | Мгновенное переключение на этот layout |
| **Кнопка в Control Center** | Открыть/закрыть панель |

### Настройки виджета

**Settings → Plugins → Mango Layouts → Switcher**:

- **Cycle on click** — вкл: левый клик циклически переключает layout; выкл: левый клик открывает панель
- **Show glyph** — показывать иконку layout в баре

## Превью в панели

Панель показывает 15 схем MangoWM в виде интерактивных карточек с миниатюрами из `ui.box`:

| Layout | Превью |
|---|---|
| Tile | Master-stack: большое слева, стек справа |
| Scroller | Горизонтальная лента окон |
| Grid | Сетка 2×2 |
| Monocle | Одно окно на весь экран |
| Deck | Стопка перекрывающихся карточек |
| Center Tile | Центральный мастер со стеками по бокам |
| Dwindle | Рекурсивное бинарное разделение |
| *(и ещё 8)* | |

Активная карточка пульсирует через анимацию `sin()`.

## Как это работает

```
MangoWM ──mmsg -w──→ service.luau ──state.set("layout")──→ widget.luau
                │                                                │
                └──mmsg -g -l (poll)──┘                          │
                                                                  ▼
                                                          panel.luau ◄── shortcut.luau
```

- `service.luau` запускает `mmsg -w` в режиме потока и опрашивает `mmsg -g -l` каждые 3 секунды
- Нормализует коды (`T`, `S`, `G`...) и полные имена (`tile`, `scroller`...) в канонические ID
- Все компоненты обмениваются состоянием через `noctalia.state.*` — без пересечения границ VM

## Лицензия

GPLv3. Смотри [LICENSE](LICENSE).
