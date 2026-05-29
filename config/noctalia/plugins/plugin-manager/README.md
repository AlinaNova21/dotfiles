# Plugin Manager

A full-featured plugin manager for Noctalia Shell with browsing, installation, and README viewer.

## Features

- **Two-column layout** — browse plugins on the left, view README on the right
- **Three tabs** — Installed, Available, and Sources management
- **README viewer** — block-based markdown rendering with headings, code blocks, lists, images, tables, blockquotes, inline emphasis (bold / italic / strikethrough) and soft line breaks
- **Remote README** — fetches README from GitHub for plugins not installed locally
- **Plugin management** — install, uninstall, update, enable/disable plugins
- **Add to bar** — one-click `+` button on any installed plugin with a `barWidget` entry point, with a cursor-positioned context menu to pick the Left / Center / Right bar section (cross-compositor: Hyprland, Niri, Sway)
- **Tag filtering** — filter available plugins by tags
- **Search** — fuzzy search across plugin names and descriptions
- **Auto-select** — automatically selects the first plugin when the panel opens or you switch tabs, so the README pane is never empty
- **Uninstall confirmation** — dialog before removing plugins
- **Fully localized** — ships with 17 locales (en, de, es, fr, it, pt, nl, ru, ja, zh-CN, zh-TW, ko-KR, tr, uk-UA, pl, sv, hu)
- **Security hardened** — plugin ID validation, HTTPS-only, URL scheme restrictions, HTML escaping, image domain whitelisting

## Dependencies

- **`markdown-it-py`** (Python, optional): used for rich markdown parsing. Falls back to Qt's built-in markdown rendering when not available.

```bash
pip install markdown-it-py
```

## IPC Commands

Toggle the plugin manager panel:

```bash
qs -c "noctalia-shell" ipc call plugin:plugin-manager toggle
```

## Screenshots

<!-- Add preview.png -->
