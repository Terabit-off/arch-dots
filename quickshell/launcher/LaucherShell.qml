import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import "."

ShellRoot {
    id: root

    property bool launcherVisible: false

    Launcher { 
        id: launcher

        visible: root.launcherVisible

        onClosed: {
            root.launcherVisible = false
        }
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.launcherVisible = !root.launcherVisible

            if (root.launcherVisible)
                launcher.open()
            else
                launcher.close()
        }

        function open(): void {
            root.launcherVisible = true
            launcher.open()
        }

        function close(): void {
            root.launcherVisible = false
            launcher.close()
        }
    }
}