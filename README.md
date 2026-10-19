# Ambxst Mods by negative127

A collection of declarative modifications and shell enhancements for the [Ambxst Desktop Environment](https://github.com/Axenide/Ambxst), powered by Ambxst's native mod manager.

---

## Available Packages

| Package | Name | Version | Description |
| :--- | :--- | :--- | :--- |
| [`screenshot-fix`](packages/screenshot-fix) | Screenshot Tool Fix | `v1.0.0` | Fixes screenshot overlay freeze and deadlock on rapid re-triggers (`SUPER + SHIFT + S`). |
| [`lenovo-conservation`](packages/lenovo-conservation) | Lenovo Conservation Mode | `v1.0.0` | Adds a toggle for Lenovo Battery Conservation Mode to the top bar battery menu. |
| [`video-wallpaper-volume`](packages/video-wallpaper-volume) | Video Wallpaper Volume | `v1.0.0` | Controls audio playback volume for video wallpapers. |

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
