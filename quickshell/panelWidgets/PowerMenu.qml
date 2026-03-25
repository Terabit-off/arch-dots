import QtQuick
import QtQuick.Layouts 
import QtQuick.Controls
import Quickshell
import Quickshell.Io

RowLayout {
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
    Process {
        id: hyprlockStart
        command: ["hyprlock"]
    }

    Button {
        text: "🔒 Lock (hyprlock)"
        onClicked: {
            hyprlockStart.running=true
        }
    } 

    Button {
        text: "shutdown"
        onClicked: {
        }
    }

    Button {
        text: "reboot"
        onClicked: {
        }
    }
}
