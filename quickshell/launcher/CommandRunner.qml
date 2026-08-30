import QtQuick
import Quickshell.Io

Item {
    id: root

    signal outputReady(string text)
    signal finished(int exitCode)

    Process {
        id: process

        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text.length > 0) {
                    root.outputReady(this.text)
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.length > 0) {
                    root.outputReady(this.text)
                }
            }
        }

        onExited: function(exitCode, exitStatus) {
            root.finished(exitCode)
        }
    }

    function run(command) {
        process.running = false

        process.command = [
            "sh",
            "-c",
            command
        ]

        process.running = true
    }

    function stop() {
        process.running = false
    }
}