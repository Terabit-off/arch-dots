import "../Singletons" as Singletons
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Item {
    id: root

    property QtObject fileSearch
    property QtObject usageStats
    property QtObject clipboardHistory
    property var clipboardResultsCache: []
    property var results: []
    property var applicationResultsCache: []
    property var fileResultsCache: []
    property string currentQuery: ""
    property string currentMode: ""
    property string modeText: "Applications"

    function normalize(text) {
        return String(text).toLowerCase().trim();
    }

    function fuzzyScore(query, text) {
        query = normalize(query);
        text = normalize(text);
        if (query.length === 0)
            return 0;

        if (text === query)
            return 10000;

        if (text.startsWith(query))
            return 8000 - text.length;

        var directIndex = text.indexOf(query);
        if (directIndex >= 0)
            return 5000 - directIndex;

        var q = 0;
        var score = 0;
        for (var i = 0; i < text.length && q < query.length; i++) {
            if (text[i] === query[q]) {
                score += 100;
                q++;
            }
        }
        if (q !== query.length)
            return -1;

        return score;
    }

    function sortResults(items, query) {
        var isEmptyQuery = normalize(query).length === 0;
        var scored = [];
        for (var i = 0; i < items.length; i++) {
            var item = items[i];
            var haystack = String(item.title || "") + " " + String(item.description || "") + " " + String(item.keywords || "");
            var score = isEmptyQuery ? 0 : fuzzyScore(query, haystack);
            if (!isEmptyQuery && score < 0)
                continue;

            var usageIndex = Number.MAX_SAFE_INTEGER;
            if (usageStats && item.type === "app") {
                var index = usageStats.indexOf(item.id);
                if (index >= 0)
                    usageIndex = index;

            }
            scored.push({
                "item": item,
                "score": score,
                "usageIndex": usageIndex
            });
        }
        scored.sort(function(a, b) {
            if (isEmptyQuery) {
                if (a.usageIndex !== b.usageIndex)
                    return a.usageIndex - b.usageIndex;

                return String(a.item.title || "").localeCompare(String(b.item.title || ""));
            }
            if (b.score !== a.score)
                return b.score - a.score;

            if (a.usageIndex !== b.usageIndex)
                return a.usageIndex - b.usageIndex;

            return String(a.item.title || "").localeCompare(String(b.item.title || ""));
        });
        var output = [];
        for (var j = 0; j < scored.length && j < 40; j++) output.push(scored[j].item)
        return output;
    }

    function search(text) {
        var query = normalize(text);
        currentQuery = query;
        if (query === "!") {
            currentMode = "clipboard";
            modeText = "Clipboard";
            results = [];
            clipboardHistory.search();
            return ;
        }
        if (query.startsWith("!") && query == "!clear") {
            currentMode = "clipboard";
            modeText = "Clipboard";
            results = [];
            clipboardHistory.clear();
            return;
        }
        if (query.startsWith("!") && query.length > 1) {
            currentMode = "clipboard";
            modeText = "Clipboard";
            clipboardResultsCache = filterClipboardResults(query.substring(1));
            results = clipboardResultsCache;
            return ;
        }
        if (query.startsWith("@")) {
            currentMode = "windows";
            modeText = "Windows";
            results = windowResults();
            return ;
        }
        if (query.length === 0) {
            currentMode = "apps";
            modeText = "Applications";
            results = applicationResults(query);
            return ;
        }
        if (isCalculation(query)) {
            currentMode = "calculator";
            modeText = "Calculator";
            results = calculatorResults(query);
            return ;
        }
        if (looksLikePath(query)) {
            currentMode = "files";
            modeText = "Files";
            fileSearch.searchHome(query);
            return ;
        }
        currentMode = "combined";
        modeText = "Applications + Files";
        applicationResultsCache = applicationResults(query);
        results = applicationResultsCache;
        fileSearch.searchHome(query);
    }

    function applicationResults(query) {
        var output = [];
        var entries = DesktopEntries.applications.values;
        for (var i = 0; i < entries.length; i++) {
            var app = entries[i];
            output.push({
                "title": app.name,
                "description": app.genericName || app.comment || "Application",
                "icon": app.icon || "",
                "type": "app",
                "id": app.id,
                "keywords": (app.keywords || []).join(" "),
                "entry": app
            });
        }
        return sortResults(output, query);
    }
    function startupResults() {
        var running = windowResults();
        var apps = applicationResults("");
        var output = [];

        if (running.length > 0) {
            for (var i = 0; i < running.length; i++)
                output.push(running[i]);
        }
        output.push({
                "type": "separator",
            });
        for (var j = 0; j < apps.length; j++)
            output.push(apps[j]);

        modeText = running.length > 0 ? "Running windows + Applications" : "Applications";
        return output;
    }
    function windowResults() {
        var output = [];
        var windowModel = Hyprland.toplevels;
        var windows = windowModel ? windowModel.values : [];
        if (!windows)
            windows = [];

        for (var i = 0; i < windows.length; i++) {
            var win = windows[i];
            if (!win || !String(win.address || ""))
                continue;

            var details = win.lastIpcObject || {};
            var windowClass = String(details.class || details.initialClass || details.initialclass || "");
            var title = String(win.title || details.title || details.initialTitle || windowClass || "Untitled window");
            var workspaceName = win.workspace
                ? String(win.workspace.name || win.workspace.id || "")
                : "";
            var descriptionParts = [];


            if (windowClass)
                descriptionParts.push(windowClass);
            if (workspaceName)
                descriptionParts.push("Workspace " + workspaceName);

            var iconName = String(win.appId || windowClass || "").toLowerCase();

            output.push({
                "title": title,
                "description": descriptionParts.join(" - ") || "Running window",
                "icon": iconName,
                "type": "window",
                "address": String(win.address),
                "activated": Boolean(win.activated),
                "keywords": windowClass + " " + String(details.initialTitle || "")
            });
        }

        // Put the focused window first; keep the rest predictable by title.
        output.sort(function(a, b) {
            if (a.activated !== b.activated)
                return a.activated ? -1 : 1;
            return String(a.title || "").localeCompare(String(b.title || ""));
        });
        return output;
    }
    function isSelectable(item) {
        return item !== null && item !== undefined && item.type !== "section";
    }

    function firstSelectableIndex() {
        for (var i = 0; i < results.length; i++) {
            if (isSelectable(results[i]))
                return i;
        }
        return 0;
    }

    function selectableCount() {
        var count = 0;
        for (var i = 0; i < results.length; i++) {
            if (isSelectable(results[i]))
                count++;
        }
        return count;
    }

    function calculatorResults(expression) {
        if (expression.length === 0)
            return [];

        var value = calculate(expression);
        if (value === null)
            return [{
            "title": "Invalid expression",
            "description": "Allowed: numbers + - * / ( ) %",
            "icon": "=",
            "type": "calculator-error"
        }];

        return [{
            "title": String(value),
            "description": expression + " = " + String(value),
            "icon": "=",
            "type": "calculator",
            "value": String(value)
        }];
    }

    function calculate(expression) {
        var e = String(expression);
        /*
         * Intentionally restricted calculator language.
         *
         * No identifiers.
         * No property access.
         * No function calls.
         * No strings.
         */
        if (!/^[0-9+\-*/().%\s]+$/.test(e))
            return null;

        e = e.replace(/%/g, "/100");
        try {
            var value = Function("\"use strict\"; return (" + e + ")")();
            if (typeof value !== "number")
                return null;

            if (!isFinite(value))
                return null;

            return Math.round(value * 1e+09) / 1e+09;
        } catch (error) {
            return null;
        }
    }

    function setFileResults(items) {
        fileResultsCache = items;
        if (currentQuery.length === 0)
            return ;

        if (currentMode === "combined") {
            results = mergeResults(applicationResultsCache, fileResultsCache);
            return ;
        }
        results = items;
    }

    function execute(item) {
        if (!item)
            return ;

        if (item.type === "clipboard") {
            clipboardHistory.copy(item);
            return ;
        }
        if (item.type === "window") {
            if (!item.address)
                return ;

            var address = String(item.address);
            if (!address.startsWith("0x"))
                address = "0x" + address;

            Hyprland.dispatch(
                'hl.dsp.focus({ window = "address:' + address + '" })'
            );
            return ;
        }
        if (item.type === "app") {
            if (usageStats)
                usageStats.record(item.id);

            if (item.entry)
                item.entry.execute();

            return ;
        }
        if (item.type === "calculator") {
            Quickshell.clipboardText = item.value;
            return ;
        }
        if (item.type === "file") {
            Quickshell.execDetached(["xdg-open", item.path]);
            return ;
        }
        if (item.type === "folder") {
            openFolder.command = ["nemo", item.path];
            openFolder.running = true;
        }
    }

    function isCalculation(text) {
        if (!/[+\-*/%]/.test(text))
            return false;

        return /^[0-9+\-*/().%\s]+$/.test(text);
    }

    function looksLikePath(text) {
        if (text.startsWith("/"))
            return true;

        if (text.startsWith("~/"))
            return true;

        if (text.startsWith("./"))
            return true;

        if (text.startsWith("../"))
            return true;

        return false;
    }

    function mergeResults(apps, files) {
        var output = [];
        for (var i = 0; i < apps.length; ++i) output.push(apps[i])
        for (var j = 0; j < files.length; ++j) output.push(files[j])
        return output.slice(0, 40);
    }

    function setClipboardResults(items) {
        clipboardResultsCache = items.slice(0, 40);
        if (currentMode !== "clipboard")
            return ;

        var query = currentQuery;
        if (query === "!") {
            results = clipboardResultsCache;
            return ;
        }
        if (query.startsWith("!"))
            results = filterClipboardResults(query.substring(1));

    }

    function filterClipboardResults(query) {
        query = normalize(query);
        if (query.length === 0)
            return clipboardResultsCache;

        var output = [];
        for (var i = 0; i < clipboardResultsCache.length; i++) {
            var item = clipboardResultsCache[i];
            var text = normalize(item.title + " " + item.description);
            if (text.indexOf(query) >= 0)
                output.push(item);

        }
        return output;
    }

    function refreshApplications() {
        if (currentQuery.length !== 0)
            return ;

        currentMode = "apps";
        modeText = "Applications";
        results = applicationResults("");
    }

    Component.onCompleted: {
        if (Singletons.AppRuntime.applicationsReady)
            root.refreshApplications();

    }

    Process {
        id: openFolder
    }

    Connections {
        function onApplicationsIndexedChanged() {
            if (Singletons.AppRuntime.applicationsIndexed)
                root.refreshApplications();

        }

        target: Singletons.AppRuntime
    }

}
