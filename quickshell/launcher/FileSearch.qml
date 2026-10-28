import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string homePath: "/home/terabit"
    property int debounceMs: 160
    property int maxResults: 40
    property int maxHomeDepth: 8
    property string pendingQuery: ""
    property string activePath: ""
    property int requestSerial: 0
    property var directoryItems: []
    property var fileItems: []
    property bool directoryFinished: false
    property bool fileFinished: false
    property bool pathProbeFound: false
    property string pendingPathCandidate: ""
    property string pendingPathParent: ""
    property string pendingPathTerm: ""

    signal resultsReady(var items)

    function stop() {
        debounce.stop();
        root.requestSerial++;
        pathProbeProcess.running = false;
        directoryProcess.running = false;
        fileProcess.running = false;
        root.directoryItems = [];
        root.fileItems = [];
        root.directoryFinished = false;
        root.fileFinished = false;
        root.pathProbeFound = false;
    }

    function search(query) {
        root.pendingQuery = String(query || "").trim();
        debounce.restart();
    }

    function searchHome(query) {
        root.pendingQuery = String(query || "").trim();
        debounce.restart();
    }

    function normalizePath(path) {
        var parts = String(path || "").split("/");
        var output = [];
        for (var i = 0; i < parts.length; i++) {
            var part = parts[i];
            if (!part || part === ".")
                continue;

            if (part === "..") {
                if (output.length > 0)
                    output.pop();

                continue;
            }
            output.push(part);
        }
        return "/" + output.join("/");
    }

    function homeRelativePath(input) {
        var value = String(input || "").trim();
        if (value === "" || value === "~" || value === "~/")
            return root.homePath;

        if (value.startsWith("~/"))
            return root.normalizePath(root.homePath + value.substring(1));

        if (value.startsWith("/"))
            return root.normalizePath(root.homePath + value);

        return root.normalizePath(root.homePath + "/" + value);
    }

    function isPathQuery(query) {
        var value = String(query || "").trim();
        return value.startsWith("/") || value.startsWith("~/") || value === "~" || value.startsWith("./") || value.startsWith("../");
    }

    function startSearch(query) {
        root.requestSerial++;
        var serial = root.requestSerial;
        pathProbeProcess.running = false;
        directoryProcess.running = false;
        fileProcess.running = false;
        root.directoryItems = [];
        root.fileItems = [];
        root.directoryFinished = false;
        root.fileFinished = false;
        root.pathProbeFound = false;
        query = String(query || "").trim();
        if (root.isPathQuery(query)) {
            root.preparePathQuery(query, serial);
            return ;
        }
        root.startGenericSearch(query, serial);
    }

    function preparePathQuery(query, serial) {
        var candidate = root.homeRelativePath(query);
        var trailingSlash = query.endsWith("/") || query.endsWith("\\");
        var slash = candidate.lastIndexOf("/");
        var parent = slash > 0 ? candidate.substring(0, slash) : root.homePath;
        var term = slash >= 0 ? candidate.substring(slash + 1) : candidate;
        root.pendingPathCandidate = candidate;
        root.pendingPathParent = parent;
        root.pendingPathTerm = term;
        if (trailingSlash) {
            root.startPathQuery(serial, candidate, parent, "", true);
            return ;
        }
        pathProbeProcess.serialForProbe = serial;
        pathProbeProcess.command = ["find", candidate, "-maxdepth", "0", "-type", "d", "-print"];
        pathProbeProcess.running = true;
    }

    function startPathQuery(serial, candidate, parent, term, exactDirectoryExists) {
        if (serial !== root.requestSerial)
            return ;

        if (exactDirectoryExists) {
            root.runDirectoryListing(serial, candidate, "");
            return ;
        }
        root.activePath = parent;
        if (!term.length) {
            root.runDirectoryListing(serial, parent, "");
            return ;
        }
        root.runPathFilteredListing(serial, parent, term);
    }

    function runDirectoryListing(serial, directory, term) {
        if (serial !== root.requestSerial)
            return ;

        root.activePath = directory;
        root.directoryFinished = false;
        root.fileFinished = false;
        root.directoryItems = [];
        root.fileItems = [];
        var effectiveTerm = String(term || "");
        var dirCommand = ["find", directory, "-mindepth", "1", "-maxdepth", "1", "-type", "d"];
        var fileCommand = ["find", directory, "-mindepth", "1", "-maxdepth", "1", "-type", "f"];
        if (effectiveTerm.length) {
            dirCommand.push("-iname", "*" + effectiveTerm + "*");
            fileCommand.push("-iname", "*" + effectiveTerm + "*");
        }
        dirCommand.push("-print");
        fileCommand.push("-print");
        directoryProcess.command = dirCommand;
        fileProcess.command = fileCommand;
        directoryProcess.running = true;
        fileProcess.running = true;
    }

    function runPathFilteredListing(serial, parent, term) {
        if (serial !== root.requestSerial)
            return ;

        root.activePath = parent;
        root.directoryFinished = false;
        root.fileFinished = false;
        root.directoryItems = [];
        root.fileItems = [];
        directoryProcess.command = ["find", parent, "-mindepth", "1", "-maxdepth", "1", "-type", "d", "-iname", "*" + term + "*", "-print"];
        fileProcess.command = ["find", parent, "-mindepth", "1", "-maxdepth", "1", "-type", "f", "-iname", "*" + term + "*", "-print"];
        directoryProcess.running = true;
        fileProcess.running = true;
    }

    function startGenericSearch(query, serial) {
        root.activePath = root.homePath;
        if (query.length < 2) {
            root.resultsReady([]);
            return ;
        }
        directoryProcess.command = ["fd", "--hidden", "--ignore-case", "--type", "d", "--max-depth", String(root.maxHomeDepth), "--max-results", String(root.maxResults), "--exclude", ".git", "--exclude", ".cache", "--exclude", "node_modules", "--exclude", ".npm", "--exclude", ".local/share/Trash", query, root.homePath];
        fileProcess.command = ["fd", "--hidden", "--ignore-case", "--type", "f", "--max-depth", String(root.maxHomeDepth), "--max-results", String(root.maxResults), "--exclude", ".git", "--exclude", ".cache", "--exclude", "node_modules", "--exclude", ".npm", "--exclude", ".local/share/Trash", query, root.homePath];
        directoryProcess.running = true;
        fileProcess.running = true;
    }

    function parseLines(text) {
        var lines = String(text || "").split("\n");
        var paths = [];
        for (var i = 0; i < lines.length; i++) {
            var path = lines[i].trim();
            if (path.length > 0)
                paths.push(path);

        }
        return paths;
    }

    function basename(path) {
        var cleanPath = String(path || "");
        var slash = cleanPath.lastIndexOf("/");
        if (slash < 0)
            return cleanPath;

        var name = cleanPath.substring(slash + 1);
        return name.length ? name : cleanPath;
    }

    function normalizeSearchText(value) {
        return String(value || "").toLowerCase();
    }

    function scoreName(path, query) {
        var name = root.normalizeSearchText(root.basename(path));
        var q = root.normalizeSearchText(query);
        if (!q.length)
            return 0;

        if (name === q)
            return 10000;

        if (name.startsWith(q))
            return 8000 - Math.min(name.length, 1000);

        var escaped = q.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
        var wordBoundary = new RegExp("(^|[._\\-\\s])" + escaped);
        if (wordBoundary.test(name))
            return 6000 - Math.min(name.length, 1000);

        var index = name.indexOf(q);
        if (index >= 0)
            return 4000 - Math.min(index * 20, 1500);

        var qi = 0;
        var score = 0;
        var lastMatch = -1;
        for (var i = 0; i < name.length && qi < q.length; i++) {
            if (name[i] === q[qi]) {
                score += 120;
                if (lastMatch >= 0 && i === lastMatch + 1)
                    score += 60;

                if (i === 0)
                    score += 200;

                lastMatch = i;
                qi++;
            }
        }
        if (qi !== q.length)
            return -1;

        score += Math.max(0, 800 - name.length);
        return score;
    }

    function makeItem(path, type, score) {
        var cleanPath = String(path || "");
        return {
            "title": type === "folder" ? displayPath(cleanPath) : type === "file" ? basename(cleanPath) : cleanPath,
            "description": type === "folder" || type === "file" ? displayPath(cleanPath) : cleanPath,
            "icon": type === "folder" ? "folder" : (root.isImage(cleanPath) ? "file://" + cleanPath : "file"),
            "type": type,
            "path": cleanPath,
            "score": Number(score || 0)
        };
    }

    function displayPath(path) {
        if (!path)
            return "";

        if (path === homePath)
            return "~";

        if (path.indexOf(homePath + "/") === 0)
            return "~" + path.substring(homePath.length);

        return path;
    }

    function currentPathTerm() {
        var query = String(root.pendingQuery || "").trim();
        if (!root.isPathQuery(query))
            return query;

        if (query.endsWith("/") || query === "~")
            return "";

        var candidate = root.homeRelativePath(query);
        var slash = candidate.lastIndexOf("/");
        if (slash < 0)
            return candidate;

        return candidate.substring(slash + 1);
    }

    function finishDirectories(text, serial) {
        if (serial !== root.requestSerial)
            return ;

        root.directoryItems = [];
        var paths = root.parseLines(text);
        var query = root.currentPathTerm();
        for (var i = 0; i < paths.length; i++) {
            var score = query.length ? root.scoreName(paths[i], query) : 0;
            if (query.length && score < 0)
                continue;

            root.directoryItems.push(root.makeItem(paths[i], "folder", score));
        }
        root.directoryFinished = true;
        root.publishIfReady();
    }

    function finishFiles(text, serial) {
        if (serial !== root.requestSerial)
            return ;

        root.fileItems = [];
        var paths = root.parseLines(text);
        var query = root.currentPathTerm();
        for (var i = 0; i < paths.length; i++) {
            var score = query.length ? root.scoreName(paths[i], query) : 0;
            if (query.length && score < 0)
                continue;

            root.fileItems.push(root.makeItem(paths[i], "file", score));
        }
        root.fileFinished = true;
        root.publishIfReady();
    }

    function publishIfReady() {
        if (!root.directoryFinished || !root.fileFinished)
            return ;

        var output = root.directoryItems.concat(root.fileItems);
        output.sort(function(a, b) {
            if (b.score !== a.score)
                return b.score - a.score;

            if (a.type !== b.type)
                return a.type === "folder" ? -1 : 1;

            return String(a.title).localeCompare(String(b.title), undefined, {
                "sensitivity": "base",
                "numeric": true
            });
        });
        root.resultsReady(output.slice(0, root.maxResults));
    }

    function isImage(path) {
        var lower = String(path || "").toLowerCase();
        return lower.endsWith(".jpg") || lower.endsWith(".jpeg") || lower.endsWith(".png") || lower.endsWith(".webp") || lower.endsWith(".gif") || lower.endsWith(".bmp") || lower.endsWith(".svg") || lower.endsWith(".avif");
    }

    Timer {
        id: debounce

        interval: root.debounceMs
        repeat: false
        onTriggered: root.startSearch(root.pendingQuery)
    }

    Process {
        id: pathProbeProcess

        property int serialForProbe: 0

        stdout: StdioCollector {
            onStreamFinished: {
                if (pathProbeProcess.serialForProbe !== root.requestSerial)
                    return ;

                root.pathProbeFound = String(this.text || "").trim().length > 0;
                root.startPathQuery(root.requestSerial, root.pendingPathCandidate, root.pendingPathParent, root.pendingPathTerm, root.pathProbeFound);
            }
        }

        stderr: StdioCollector {
        }

    }

    Process {
        id: directoryProcess

        stdout: StdioCollector {
            onStreamFinished: root.finishDirectories(this.text || "", root.requestSerial)
        }

        stderr: StdioCollector {
        }

    }

    Process {
        id: fileProcess

        stdout: StdioCollector {
            onStreamFinished: root.finishFiles(this.text || "", root.requestSerial)
        }

        stderr: StdioCollector {
        }

    }

}
