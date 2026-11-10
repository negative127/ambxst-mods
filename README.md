# Ambxst Mods

A collection of mods for [Ambxst](https://github.com/Axenide/Ambxst) (applied through Ambxst's native mod manager) 

---

## Available Packages

| Package | Name | Version | Description |
| :--- | :--- | :--- | :--- |
| [`improved-launcher`](packages/improved-launcher) | Improved Launcher | `v1.1.0` | Smart multi-provider search enhancements for the application launcher: inline math & unit evaluation via `qalc`, GUI calculator bridge, terminal command execution, and fallback web search. |
| [`clipboard-fix`](packages/clipboard-fix) | Clipboard Fix | `v1.0.0` | Fixes click-to-copy reliability, restores preview panel Open and Drag actions, and corrects selected item highlight bounds and list jitter. |
| [`screenshot-fix`](packages/screenshot-fix) | Screenshot Tool Fix | `v1.0.0` | Fixes screenshot overlay freeze and deadlock on rapid re-triggers (`SUPER + SHIFT + S`). |
| [`lenovo-conservation`](packages/lenovo-conservation) | Lenovo Conservation Mode | `v1.0.0` | Adds a toggle for Lenovo Battery Conservation Mode to the top bar battery menu. |

---

## Installation

### Local Install (Recommended)

```bash
ambxst mods install /home/negative/ambxst-mods/packages/<package-name>
ambxst mods enable negative.<package-id>
ambxst reload
```

### Git Install

```bash
ambxst mods install https://github.com/negative127/ambxst-mods/tree/main/packages/<package-name>
ambxst mods enable negative.<package-id>
ambxst reload
```

---

## License

All packages in this repository are licensed under the MIT License unless explicitly specified otherwise within a package directory.
