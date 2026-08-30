pragma Singleton

import Quickshell.Services.UPower
import QtQuick

QtObject {
    readonly property var battery: UPower.displayDevice
    property var modIcon: ""


    function setModIcon(state) {
        // p = power, s = save
        if (state === "p") {
            modIcon = "󱐋 "
            return
        } else if (state === "s") {
            modIcon = "󰌪 "
            return
        }
        modIcon = ""
    }
}