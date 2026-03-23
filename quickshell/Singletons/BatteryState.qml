pragma Singleton

import Quickshell.Services.UPower
import QtQuick

QtObject {
    readonly property var battery: UPower.displayDevice
}