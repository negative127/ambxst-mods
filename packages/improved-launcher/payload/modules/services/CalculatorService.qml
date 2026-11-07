pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.config
import qs.modules.services

Singleton {
    id: root

    readonly property string modId: "negative.improved-launcher"
    property string expression: ""
    property bool expressionHadPrefix: false
    property string result: ""
    property bool isCalculating: false
    property bool hasResult: false
    property string activeQuery: ""
    property int evalId: 0
    property int runningEvalId: 0

    // Settings
    property string row1Display: "result"         // "result" | "equation"
    property string enterAction: "result"         // "result" | "equation"
    property string shiftEnterAction: "equation"  // "equation" | "result" | "calculator"
    property string calculatorApp: "kcalc"
    property bool enableTerminal: true
    property bool enableWebSearch: true
    property string searchEngine: "google"        // "google" | "duckduckgo" | "brave" | "bing"

    readonly property string equation: (root.hasResult && root.result.length > 0)
        ? `${root.expression} = ${root.result}`
        : ""

    // 35ms debounce timer to prevent excessive subprocess spawning
    Timer {
        id: debounceTimer
        interval: 35
        repeat: false
        onTriggered: root.executeCalculation()
    }

    Process {
        id: mathProc
        property var baseCommand: ["qalc", "-t"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                // Ignore output if this is from a stale evaluation
                if (root.runningEvalId !== root.evalId || !root.shouldEvaluate(root.activeQuery)) {
                    root.hasResult = false;
                    root.result = "";
                    return;
                }

                let trimmed = data.trim();
                if (trimmed.length > 0 && trimmed !== "..." && !trimmed.startsWith("error:") && !trimmed.startsWith("warning:")) {
                    if (root.isMeaningfulCalculation(root.expression, trimmed, root.expressionHadPrefix)) {
                        root.result = trimmed;
                        root.hasResult = true;
                        return;
                    }
                }
                root.hasResult = false;
                root.result = "";
            }
        }

        onExited: exitCode => {
            root.isCalculating = false;
            if (exitCode !== 0 || root.runningEvalId !== root.evalId || !root.shouldEvaluate(root.activeQuery)) {
                root.hasResult = false;
                root.result = "";
            }
        }
    }

    function isMeaningfulCalculation(expr, res, hadPrefix) {
        if (hadPrefix) return true;
        let cleanExpr = expr.replace(/\s+/g, "").replace(/,/g, "").toLowerCase();
        let cleanRes = res.replace(/\s+/g, "").replace(/,/g, "").toLowerCase();
        return cleanExpr !== cleanRes;
    }

    function shouldEvaluate(query) {
        if (!query || query.length === 0) return false;
        
        let mathPrefix = (Config.prefix && Config.prefix.math) ? Config.prefix.math : "=";
        if (query.startsWith(mathPrefix)) return true;

        if (/^\s*\d/.test(query)) return true;
        if (/^\s*[\(\+\-]\s*\d/.test(query)) return true;
        if (/^\s*(sqrt|cbrt|sin|cos|tan|asin|acos|atan|log|ln|abs|exp)\s*\(/i.test(query)) return true;
        if (/^\s*\d+.*(to|in)\s+[a-zA-Z]+/i.test(query)) return true;

        return false;
    }

    function normalizeExpression(expr) {
        if (!expr) return "";
        let trimmed = expr.trim();

        // 1. Temperature conversions (e.g., '100 c in f', '212 f to c')
        let tempM = trimmed.match(/^([-+]?[0-9]*\.?[0-9]+)\s*(?:°?\s*c|celsius|degc)\s+(?:in|to|as)\s+(?:°?\s*f|fahrenheit|degf)$/i);
        if (tempM) {
            return tempM[1] + " celsius to fahrenheit";
        }
        let tempM2 = trimmed.match(/^([-+]?[0-9]*\.?[0-9]+)\s*(?:°?\s*f|fahrenheit|degf)\s+(?:in|to|as)\s+(?:°?\s*c|celsius|degc)$/i);
        if (tempM2) {
            return tempM2[1] + " fahrenheit to celsius";
        }

        // 2. Conversion preposition " in " -> " to "
        if (trimmed.indexOf(" to ") === -1 && trimmed.indexOf(" as ") === -1) {
            let inMatch = trimmed.match(/^(.*?\S)\s+in\s+([a-zA-Z$€£¥₹°%]+(?:\/[a-zA-Z$€£¥₹°%]+)?(?:\^[0-9]+)?)$/i);
            if (inMatch) {
                trimmed = inMatch[1] + " to " + inMatch[2];
            }
        }

        // 3. Clean decimal format: prefix target unit with "-" to prevent mixed unit breakdown (e.g. lbs + oz -> lb)
        let toMatch = trimmed.match(/^(.*?\S)\s+to\s+([a-zA-Z$€£¥₹°%]+(?:\/[a-zA-Z$€£¥₹°%]+)?(?:\^[0-9]+)?)$/i);
        if (toMatch) {
            let target = toMatch[2];
            if (!target.startsWith("-") && !target.startsWith("+")) {
                trimmed = toMatch[1] + " to -" + target;
            }
        }

        return trimmed;
    }

    function evaluate(query) {
        root.evalId++;
        root.activeQuery = query;
        if (!shouldEvaluate(query)) {
            debounceTimer.stop();
            mathProc.running = false;
            root.hasResult = false;
            root.result = "";
            root.expression = "";
            root.expressionHadPrefix = false;
            return;
        }

        let mathPrefix = (Config.prefix && Config.prefix.math) ? Config.prefix.math : "=";
        let expr = query;
        let hadPrefix = false;
        if (expr.startsWith(mathPrefix)) {
            expr = expr.slice(mathPrefix.length).trim();
            hadPrefix = true;
        }

        if (expr.length === 0) {
            debounceTimer.stop();
            mathProc.running = false;
            root.hasResult = false;
            root.result = "";
            root.expression = "";
            root.expressionHadPrefix = hadPrefix;
            return;
        }

        root.expression = expr;
        root.expressionHadPrefix = hadPrefix;
        debounceTimer.restart();
    }

    function executeCalculation() {
        if (!root.expression || root.expression.length === 0) return;

        root.runningEvalId = root.evalId;
        mathProc.running = false;
        let normalized = root.normalizeExpression(root.expression);
        mathProc.command = mathProc.baseCommand.concat(normalized);
        root.isCalculating = true;
        mathProc.running = true;
    }

    function copyResult() {
        if (root.hasResult && root.result.length > 0) {
            Quickshell.clipboardText = root.result;
            BackendService.call("clipboard.copyText", { text: root.result }, (res, err) => {
                if (err) console.warn("CalculatorService: copyText failed:", err);
            });
        }
    }

    function copyEquation() {
        let eq = root.equation;
        if (eq.length > 0) {
            Quickshell.clipboardText = eq;
            BackendService.call("clipboard.copyText", { text: eq }, (res, err) => {
                if (err) console.warn("CalculatorService: copyText failed:", err);
            });
        }
    }

    function openCalculator(expr) {
        let e = (expr !== undefined && expr !== null && String(expr).trim().length > 0)
            ? String(expr).trim()
            : root.expression.trim();
        let app = (root.calculatorApp && root.calculatorApp.trim().length > 0)
            ? root.calculatorApp.trim()
            : "kcalc";

        if (e.startsWith("=")) {
            e = e.slice(1).trim();
        }

        let script = `
            EXPR="$1"
            APP="$2"
            wl-copy "$EXPR" 2>/dev/null || true
            if [ "$APP" = "kcalc" ]; then
                WAS_RUNNING=0
                if pgrep -x kcalc > /dev/null; then
                    WAS_RUNNING=1
                else
                    kcalc &
                    for i in {1..30}; do
                        sleep 0.08
                        BUS=$(busctl --user list 2>/dev/null | awk '/kcalc/{print $1}' | head -n 1)
                        [ -n "$BUS" ] && break
                    done
                    sleep 0.15
                fi
                BUS=$(busctl --user list 2>/dev/null | awk '/kcalc/{print $1}' | head -n 1)
                if [ -n "$BUS" ]; then
                    busctl --user call "$BUS" /kcalc/MainWindow_1 org.qtproject.Qt.QWidget activateWindow >/dev/null 2>&1 || true
                    busctl --user call "$BUS" /kcalc/MainWindow_1 org.qtproject.Qt.QWidget raise >/dev/null 2>&1 || true
                    if [ "$WAS_RUNNING" -eq 1 ]; then
                        wtype -k Escape 2>/dev/null || true
                        sleep 0.05
                    fi
                    busctl --user call "$BUS" /kcalc/MainWindow_1 org.kde.KMainWindow activateAction s "edit_paste" >/dev/null 2>&1
                else
                    sleep 0.3
                    wtype -M ctrl -k v -m ctrl 2>/dev/null || wtype "$EXPR" 2>/dev/null || true
                fi
            else
                $APP &
                sleep 0.4
                wtype -M ctrl -k v -m ctrl 2>/dev/null || wtype "$EXPR" 2>/dev/null || true
            fi
        `;
        Quickshell.execDetached(["bash", "-c", script, "_", e, app]);
    }

    function searchWeb(query) {
        let q = (query !== undefined && query !== null && String(query).trim().length > 0)
            ? String(query).trim()
            : root.expression.trim();
        if (q.startsWith("=")) q = q.slice(1).trim();

        let base = "https://www.google.com/search?q=";
        if (root.searchEngine === "duckduckgo") {
            base = "https://duckduckgo.com/?q=";
        } else if (root.searchEngine === "brave") {
            base = "https://search.brave.com/search?q=";
        } else if (root.searchEngine === "bing") {
            base = "https://www.bing.com/search?q=";
        }
        Qt.openUrlExternally(base + encodeURIComponent(q));
    }

    function runInTerminal(cmd) {
        let c = (cmd !== undefined && cmd !== null && String(cmd).trim().length > 0)
            ? String(cmd).trim()
            : root.expression.trim();
        if (c.startsWith("=")) c = c.slice(1).trim();
        TerminalService.execDetached(c + "; echo; echo 'Press Enter to exit'; read line");
    }

    function performEnterAction() {
        if (root.enterAction === "equation") {
            root.copyEquation();
        } else {
            root.copyResult();
        }
    }

    function performShiftEnterAction() {
        if (root.shiftEnterAction === "result") {
            root.copyResult();
        } else if (root.shiftEnterAction === "calculator") {
            root.openCalculator(root.expression);
        } else {
            root.copyEquation();
        }
    }

    function applySetting(key, val) {
        if (key === "row1Display" && (val === "result" || val === "equation")) {
            root.row1Display = val;
        } else if (key === "enterAction" && (val === "result" || val === "equation")) {
            root.enterAction = val;
        } else if (key === "shiftEnterAction" && (val === "equation" || val === "result" || val === "calculator")) {
            root.shiftEnterAction = val;
        } else if (key === "calculatorApp" && typeof val === "string") {
            root.calculatorApp = val;
        } else if (key === "enableTerminal" && typeof val === "boolean") {
            root.enableTerminal = val;
        } else if (key === "enableWebSearch" && typeof val === "boolean") {
            root.enableWebSearch = val;
        } else if (key === "searchEngine" && typeof val === "string") {
            root.searchEngine = val;
        }
    }

    function applySettings(values) {
        if (!values) return;
        for (let k in values) {
            root.applySetting(k, values[k]);
        }
    }

    Component.onCompleted: {
        if (typeof ModsService !== "undefined" && typeof ModsService.getSettings === "function") {
            ModsService.getSettings(root.modId, (settings, error) => {
                if (!error && settings && settings.values) {
                    root.applySettings(settings.values);
                }
            });
        }
    }

    Connections {
        target: (typeof ModsService !== "undefined") ? ModsService : null
        function onSettingChanged(id, key, value) {
            if (id === root.modId) {
                root.applySetting(key, value);
            }
        }
    }
}
