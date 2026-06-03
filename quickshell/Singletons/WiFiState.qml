pragma Singleton

import QtQuick
import Quickshell.Networking

QtObject {
    readonly property var networking: Networking

    readonly property bool wifiEnabled: Networking.wifiEnabled

    readonly property bool internetAvailable:
        Networking.connectivity === NetworkConnectivity.Full

    readonly property bool captivePortal:
        Networking.connectivity === NetworkConnectivity.Portal

    readonly property bool limitedConnectivity:
        Networking.connectivity === NetworkConnectivity.Limited

    property var wifiDevice: null

    property var networks: []

    function refreshNetworks() {
        if (!wifiDevice)
            return

        networks = [...wifiDevice.networks]
            .sort((a, b) => b.signalStrength - a.signalStrength)
    }

    function connect(network) {
        network.connect()
    }

    function disconnect(network) {
        network.disconnect()
    }

    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled
    }

    Component.onCompleted: {
        for (const device of Networking.devices) {
            if (device.type === DeviceType.Wifi) {
                wifiDevice = device
                break
            }
        }

        refreshNetworks()
    }
}