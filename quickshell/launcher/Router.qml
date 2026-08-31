import QtQuick
import Quickshell

QtObject {
    id: root

    property QtObject fileSearch

    property var results: []

    property var applicationResultsCache: []
    property var fileResultsCache: []

    property string currentQuery: ""
    property string currentMode: ""

    property string modeText: "Applications"


    function normalize(text) {
        return String(text).toLowerCase().trim()
    }
    

    function fuzzyScore(query, text) {
        query = normalize(query)
        text = normalize(text)

        if (query.length === 0)
            return 0

        if (text === query)
            return 10000

        if (text.startsWith(query))
            return 8000 - text.length

        var directIndex = text.indexOf(query)

        if (directIndex >= 0)
            return 5000 - directIndex

        var q = 0
        var score = 0

        for (var i = 0; i < text.length && q < query.length;i++) {

            if (text[i] === query[q]) {
                score += 100
                q++
            }
        }

        if (q !== query.length)
            return -1

        return score
    }

    function sortResults(items, query) {
        var scored = []

        for (var i = 0; i < items.length; i++) {
            var item = items[i]

            var haystack =
                String(item.title || "") + " " +
                String(item.description || "") + " " +
                String(item.keywords || "")

            var score = fuzzyScore(query, haystack)

            if (score >= 0) {
                scored.push({
                    item: item,
                    score: score
                })
            }
        }

        scored.sort(function(a, b) {
            return b.score - a.score
        })

        var output = []

        for (var j = 0;
             j < scored.length && j < 40;
             j++) {

            output.push(scored[j].item)
        }

        return output
    }

    function search(text) {
        var query = normalize(text)

        currentQuery = query

        if (query.length === 0) {
            currentMode = "apps"
            modeText = "Applications"

            results = applicationResults("")

            return
        }

        if (isCalculation(query)) {
            currentMode = "calculator"
            modeText = "Calculator"

            results = calculatorResults(query)

            return
        }

        if (looksLikePath(query)) {
            currentMode = "files"
            modeText = "Files"

            fileSearch.searchHome(query)

            return
        }

        currentMode = "combined"
        modeText = "Applications + Files"

        applicationResultsCache =
            applicationResults(query)

        results =
            applicationResultsCache

        fileSearch.searchHome(query)
    }

    function applicationResults(query) {
        var output = []

        var entries = DesktopEntries.applications.values

        for (var i = 0; i < entries.length; i++) {
            var app = entries[i]

            output.push({
                title: app.name,

                description:
                    app.genericName ||
                    app.comment ||
                    "Application",

                icon: app.icon || "•",

                type: "app",
                id: app.id,

                keywords:
                    (app.keywords || []).join(" "),

                entry: app
            })
        }

        return sortResults(output, query)
    }

    function calculatorResults(expression) {
        if (expression.length === 0)
            return []

        var value = calculate(expression)

        if (value === null) {
            return [{
                title: "Invalid expression",

                description:
                    "Allowed: numbers + - * / ( ) %",

                icon: "=",

                type: "calculator-error"
            }]
        }

        return [{
            title: String(value),

            description:
                expression + " = " + String(value),

            icon: "=",

            type: "calculator",

            value: String(value)
        }]
    }

    function calculate(expression) {
        var e = String(expression)

        /*
         * Intentionally restricted calculator language.
         *
         * No identifiers.
         * No property access.
         * No function calls.
         * No strings.
         */
        if (!/^[0-9+\-*/().%\s]+$/.test(e))
            return null

        e = e.replace(/%/g, "/100")

        try {
            var value = Function(
                "\"use strict\"; return (" + e + ")"
            )()

            if (typeof value !== "number")
                return null

            if (!isFinite(value))
                return null

            return Math.round(
                value * 1000000000
            ) / 1000000000

        } catch (error) {
            return null
        }
    }

    function setFileResults(items) {
        fileResultsCache = items

        if (currentQuery.length === 0)
            return

        if (currentMode === "combined") {
            results = mergeResults(
                applicationResultsCache,
                fileResultsCache
            )

            return
        }

        results = items
    }

    function execute(item) {
        if (!item)
            return

        if (item.type === "app") {
            if (item.entry)
                item.entry.execute()

            return
        }

        if (item.type === "calculator") {
            Quickshell.clipboardText = item.value
            return
        }

        if (item.type === "file") {
            Quickshell.execDetached([
                "xdg-open",
                item.path
            ])

            return
        }
    }

    function isCalculation(text) {
        if (!/[+\-*/%]/.test(text))
            return false
            
        return /^[0-9+\-*/().%\s]+$/.test(text)
    }

    function looksLikePath(text) {
        if (text.startsWith("/"))
            return true

        if (text.startsWith("~/"))
            return true

        if (text.startsWith("./"))
            return true

        if (text.startsWith("../"))
            return true

        return false
    }

    function mergeResults(apps, files) {
        var output = []

        for (var i = 0; i < apps.length; ++i)
            output.push(apps[i])

        for (var j = 0; j < files.length; ++j)
            output.push(files[j])

        return output.slice(0, 40)
    }
}