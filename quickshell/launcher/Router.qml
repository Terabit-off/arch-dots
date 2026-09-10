import QtQuick
import Quickshell

Item {
    id: root

    property QtObject fileSearch
    property QtObject usageStats
    property QtObject clipboardHistory

    property var clipboardResultsCache: []
    property var results: []
    property var applicationResultsCache: []
    property var fileResultsCache: []
    property var applicationIndex: []

    property string currentQuery: ""
    property string currentMode: ""
    property string modeText: "Applications"


    Connections {
        target: usageStats

        function onChanged() {
            if (root.currentQuery === "" && root.currentMode === "apps")
                root.results = root.applicationResults("")
        }
    }

    Timer {
        id: applicationsLoader

        interval: 100
        repeat: true
        running: true

        onTriggered: {
            var entries = DesktopEntries.applications.values

            if (entries.length === 0)
                return

            stop()
            root.refreshApplications()
        }
    }

    function normalize(text) {
        return String(text || "").toLowerCase().trim()
    }

    function fuzzyScore(query, text) {
        query = normalize(query)
        text = normalize(text)

        if (query.length === 0)
            return 0

        if (text === query)
            return 10000

        if (text.startsWith(query))
            return 8000 - Math.min(text.length, 1000)

        var directIndex = text.indexOf(query)
        if (directIndex >= 0)
            return 5000 - Math.min(directIndex, 1000)

        var queryIndex = 0
        var score = 0
        var lastMatch = -1

        for (var i = 0; i < text.length && queryIndex < query.length; i++) {
            if (text[i] !== query[queryIndex])
                continue

            // Consecutive characters are a stronger match.
            score += (lastMatch === i - 1) ? 140 : 80

            // Earlier matches are preferable.
            score += Math.max(0, 20 - i)

            lastMatch = i
            queryIndex++
        }

        if (queryIndex !== query.length)
            return -1

        return score
    }

    function usageRanks() {
        var ranks = {}

        if (!usageStats || !Array.isArray(usageStats.data))
            return ranks

        for (var i = 0; i < usageStats.data.length; i++) {
            var id = String(usageStats.data[i] || "")
            if (id && ranks[id] === undefined)
                ranks[id] = i
        }

        return ranks
    }

    function sortResults(items, query) {
        var normalizedQuery = normalize(query)
        var isEmptyQuery = normalizedQuery.length === 0
        var scored = []
        var ranks = usageRanks()

        for (var i = 0; i < items.length; i++) {
            var item = items[i]
            var score = 0

            if (!isEmptyQuery) {
                // Title gets the highest priority. Keywords/description are fallback.
                var titleScore = fuzzyScore(normalizedQuery, item.title || "")
                var keywordScore = fuzzyScore(normalizedQuery, item.keywords || "")
                var descriptionScore = fuzzyScore(normalizedQuery, item.description || "")

                score = Math.max(
                    titleScore,
                    keywordScore >= 0 ? keywordScore - 500 : -1,
                    descriptionScore >= 0 ? descriptionScore - 1000 : -1
                )

                if (score < 0)
                    continue
            }

            var usageIndex = Number.MAX_SAFE_INTEGER
            if (item.type === "app" && item.id && ranks[item.id] !== undefined)
                usageIndex = ranks[item.id]

            scored.push({
                item: item,
                score: score,
                usageIndex: usageIndex
            })
        }

        scored.sort(function(a, b) {
            if (isEmptyQuery) {
                if (a.usageIndex !== b.usageIndex)
                    return a.usageIndex - b.usageIndex
            } else if (b.score !== a.score) {
                return b.score - a.score
            } else if (a.usageIndex !== b.usageIndex) {
                return a.usageIndex - b.usageIndex
            }

            return String(a.item.title || "").localeCompare(
                String(b.item.title || "")
            )
        })

        var output = []
        for (var j = 0; j < scored.length && j < 40; j++)
            output.push(scored[j].item)

        return output
    }

    function clearFileSearch() {
        if (fileSearch)
            fileSearch.stop()

        fileResultsCache = []
    }

    function search(text) {
        var query = normalize(text)
        currentQuery = query

        if (query === "!") {
            clearFileSearch()
            currentMode = "clipboard"
            modeText = "Clipboard"
            results = []
            clipboardHistory.search()
            return
        }

        if (query.startsWith("!") && query.length > 1) {
            clearFileSearch()
            currentMode = "clipboard"
            modeText = "Clipboard"
            results = filterClipboardResults(query.substring(1))
            return
        }

        if (query.length === 0) {
            clearFileSearch()
            currentMode = "apps"
            modeText = "Applications"
            results = applicationResults("")
            return
        }

        if (isCalculation(query)) {
            clearFileSearch()
            currentMode = "calculator"
            modeText = "Calculator"
            results = calculatorResults(query)
            return
        }

        if (looksLikePath(query)) {
            currentMode = "files"
            modeText = "Files"
            applicationResultsCache = []
            fileSearch.search(query)
            return
        }

        currentMode = "combined"
        modeText = "Applications + Files"
        applicationResultsCache = applicationResults(query)
        results = applicationResultsCache

        // Avoid spawning fd for one-character generic queries.
        if (query.length >= 2)
            fileSearch.searchHome(query)
        else
            clearFileSearch()
    }

    function applicationResults(query) {
        if (applicationIndex.length === 0)
            refreshApplicationIndex()

        return sortResults(applicationIndex, query)
    }

    function refreshApplicationIndex() {
        var entries = DesktopEntries.applications.values
        var output = []

        for (var i = 0; i < entries.length; i++) {
            var app = entries[i]
            var keywords = (app.keywords || []).join(" ")

            output.push({
                title: app.name || "",
                description: app.genericName || app.comment || "Application",
                icon: app.icon || "",
                type: "app",
                id: app.id,
                keywords: keywords,
                entry: app
            })
        }

        applicationIndex = output
    }

    function calculatorResults(expression) {
        var value = calculate(expression)

        if (value === null) {
            return [{
                title: "Invalid expression",
                description: "Allowed: numbers + - * / ( ) and postfix %",
                icon: "=",
                type: "calculator-error"
            }]
        }

        return [{
            title: String(value),
            description: expression + " = " + String(value),
            icon: "=",
            type: "calculator",
            value: String(value)
        }]
    }

    function calculate(expression) {
        var source = String(expression || "")

        if (!/^[0-9+\-*/().%\s]+$/.test(source))
            return null

        // Recursive-descent parser. No user input is ever executed as JavaScript.
        var parser = {
            source: source,
            pos: 0,

            skipSpaces: function() {
                while (this.pos < this.source.length && /\s/.test(this.source[this.pos]))
                    this.pos++
            },

            parseExpression: function() {
                return this.parseAddSub()
            },

            parseAddSub: function() {
                var value = this.parseMulDiv()
                if (value === null)
                    return null

                while (true) {
                    this.skipSpaces()
                    if (this.pos >= this.source.length)
                        return value

                    var op = this.source[this.pos]
                    if (op !== "+" && op !== "-")
                        return value

                    this.pos++
                    var rhs = this.parseMulDiv()
                    if (rhs === null)
                        return null

                    value = op === "+" ? value + rhs : value - rhs
                }
            },

            parseMulDiv: function() {
                var value = this.parseUnary()
                if (value === null)
                    return null

                while (true) {
                    this.skipSpaces()
                    if (this.pos >= this.source.length)
                        return value

                    var op = this.source[this.pos]
                    if (op !== "*" && op !== "/")
                        return value

                    this.pos++
                    var rhs = this.parseUnary()
                    if (rhs === null)
                        return null

                    if (op === "/" && rhs === 0)
                        return null

                    value = op === "*" ? value * rhs : value / rhs
                }
            },

            parseUnary: function() {
                this.skipSpaces()

                var sign = 1
                while (this.pos < this.source.length) {
                    var op = this.source[this.pos]
                    if (op === "+") {
                        this.pos++
                    } else if (op === "-") {
                        sign *= -1
                        this.pos++
                    } else {
                        break
                    }
                    this.skipSpaces()
                }

                var value = this.parsePrimary()
                if (value === null)
                    return null

                return sign * value
            },

            parsePrimary: function() {
                this.skipSpaces()

                if (this.pos >= this.source.length)
                    return null

                if (this.source[this.pos] === "(") {
                    this.pos++
                    var nested = this.parseExpression()
                    this.skipSpaces()

                    if (this.source[this.pos] !== ")")
                        return null

                    this.pos++
                    return this.parsePercent(nested)
                }

                var start = this.pos
                var sawDigit = false
                var sawDot = false

                while (this.pos < this.source.length) {
                    var ch = this.source[this.pos]

                    if (ch >= "0" && ch <= "9") {
                        sawDigit = true
                        this.pos++
                        continue
                    }

                    if (ch === "." && !sawDot) {
                        sawDot = true
                        this.pos++
                        continue
                    }

                    break
                }

                if (!sawDigit)
                    return null

                var value = Number(this.source.substring(start, this.pos))
                if (!isFinite(value))
                    return null

                return this.parsePercent(value)
            },

            parsePercent: function(value) {
                this.skipSpaces()
                while (this.source[this.pos] === "%") {
                    value /= 100
                    this.pos++
                    this.skipSpaces()
                }
                return value
            }
        }

        var value = parser.parseExpression()
        parser.skipSpaces()

        if (value === null || parser.pos !== source.length || !isFinite(value))
            return null

        return Math.round(value * 1000000000) / 1000000000
    }

    function setFileResults(items) {
        if (currentQuery.length === 0 || currentMode !== "files" && currentMode !== "combined")
            return

        fileResultsCache = items || []

        if (currentMode === "combined") {
            results = mergeResults(applicationResultsCache, fileResultsCache)
            return
        }

        results = fileResultsCache
    }

    function execute(item) {
        if (!item)
            return

        if (item.type === "clipboard") {
            clipboardHistory.copy(item)
            return
        }

        if (item.type === "app") {
            if (usageStats)
                usageStats.record(item.id)

            if (item.entry)
                item.entry.execute()
            return
        }

        if (item.type === "calculator") {
            Quickshell.clipboardText = item.value
            return
        }

        if (item.type === "file") {
            Quickshell.execDetached(["xdg-open", item.path])
        }
    }

    function isCalculation(text) {
        if (!/[+\-*/%]/.test(text))
            return false

        return /^[0-9+\-*/().%\s]+$/.test(text)
    }

    function looksLikePath(text) {
        return text.startsWith("/") ||
               text.startsWith("~/") ||
               text.startsWith("./") ||
               text.startsWith("../")
    }

    function mergeResults(apps, files) {
        var output = []
        var i

        for (i = 0; i < apps.length && output.length < 40; i++)
            output.push(apps[i])

        for (var j = 0; j < files.length && output.length < 40; j++)
            output.push(files[j])

        return output
    }

    function setClipboardResults(items) {
        clipboardResultsCache = (items || []).slice(0, 40)

        if (currentMode !== "clipboard")
            return

        if (currentQuery === "!") {
            results = clipboardResultsCache
            return
        }

        if (currentQuery.startsWith("!"))
            results = filterClipboardResults(currentQuery.substring(1))
    }

    function filterClipboardResults(query) {
        query = normalize(query)

        if (query.length === 0)
            return clipboardResultsCache

        var output = []

        for (var i = 0; i < clipboardResultsCache.length; i++) {
            var item = clipboardResultsCache[i]
            var text = normalize(
                String(item.title || "") + " " + String(item.description || "")
            )

            if (text.indexOf(query) >= 0)
                output.push(item)
        }

        return output
    }

    function refreshApplications() {
        refreshApplicationIndex()

        if (currentQuery.length !== 0)
            return

        currentMode = "apps"
        modeText = "Applications"
        results = applicationResults("")
    }
}
