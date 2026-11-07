# Improved Launcher

Smart multi-provider search enhancements for the Ambxst application launcher: inline mathematical and unit evaluation via `qalc`, GUI calculator integration, terminal command execution, and fallback web search.

---

## Features

### 1. Instant Inline Math & Unit Calculator
- Evaluates arithmetic, algebra, trigonometry, and scientific expressions (`sqrt(25)`, `(100+50)/2`, `sin(pi/2)`).
- Supports real-time currency and unit conversions (`100 usd in inr`, `50 km to miles`, `100 c in f`).
- Hybrid detection: activates automatically on mathematical inputs or with explicit `=` prefix (e.g. `= 42 * 2`).
- Monospace result display with customizable copy actions.

### 2. GUI Calculator Bridge (`kcalc`)
- Select **Open in Calculator** (or use Shift+Enter / right-click menu) to open your desktop calculator with the expression already typed and evaluated.
- Automatic clear and paste via KCalc session DBus integration, with fallback support for other calculator apps.

### 3. Fallback Terminal & Web Search
- **Run in terminal**: Launch any shell command (e.g. `btop`, `nmtui`) directly in your default terminal via Ambxst's `TerminalService`.
- **Web search**: Search the web using your preferred search engine (Google, DuckDuckGo, Brave Search, Bing).
- **Never a dead end**: When a query doesn't match an installed desktop app, terminal runner and web search cards are promoted to the top.

### 4. Zero Layout Resizing or Glitches
- Maintains Ambxst's standard launcher height (296px).
- Zero window jumping, teleportation, or animation lag.
- 100% universal compatibility: works out of the box on stock Ambxst and with mods like `drpezzer.roadie`.

---

## Configuration

Customizable via **Settings > Mods > Improved Launcher**:
- **Math row display format**: Result only (`5`) or Full equation (`sqrt(25) = 5`).
- **Enter key action**: Copy Result to clipboard or Copy Full Equation.
- **Shift + Enter action**: Copy Full Equation, Copy Result, or Open in Calculator.
- **Calculator app command**: Default `kcalc` (configurable for `gnome-calculator`, `galculator`, etc.).
- **Enable Run in Terminal**: Toggle terminal command card.
- **Enable Web Search**: Toggle web search card.
- **Default web search engine**: Select Google, DuckDuckGo, Brave Search, or Bing.

---

## Dependencies
- `qalc` (`libqalculate`): Required for inline math and conversion evaluations.
- `kcalc` (or your preferred desktop calculator): Optional, for GUI calculator launch.
