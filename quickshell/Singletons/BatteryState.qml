import QtQuick
import Quickshell.Services.UPower
pragma Singleton

Item {
    readonly property var battery: UPower.displayDevice
    property string modIcon: ""

    function setModIcon(state) {
        switch (state) {
        case "p":
            modIcon = "󱐋 ";
            break;
        case "s":
            modIcon = "󰌪 ";
            break;
        case "b":
            modIcon = "";
            break;
        default:
            modIcon = "";
            break;
        }
    }

    function syncPowerProfile() {
        switch (PowerProfiles.profile) {
        case PowerProfile.PowerSaver:
            setModIcon("s");
            break;
        case PowerProfile.Performance:
            setModIcon("p");
            break;
        case PowerProfile.Balanced:
            setModIcon("b");
            break;
        default:
            setModIcon("");
            break;
        }
    }

    Component.onCompleted: syncPowerProfile()

    Connections {
        function onProfileChanged() {
            BatteryState.syncPowerProfile();
        }

        target: PowerProfiles
    }

}
