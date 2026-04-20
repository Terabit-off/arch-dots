import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Io


import "../Singletons" as Singletons

Rectangle {
    id: timeDateModule
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.maximumHeight: 40
    border.color: Singletons.Colors.moduleBorderColor
    color: Singletons.Colors.moduleBackgroundColor
    radius: Singletons.Colors.moduleBorderRadius

    function upd(){
        time.text = Qt.formatDateTime(new Date(), "HH:mm");
        date.text = Qt.formatDateTime(new Date(), "dd-MM-yyyy");
        day.text = Qt.formatDateTime(new Date(), "ddd");
    }

    RowLayout {
        anchors.fill: parent
        anchors.centerIn: parent
        spacing: 0
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: 'transparent'
            Text {
                id: time
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: Qt.formatDateTime(new Date(), "HH:mm");
                anchors.centerIn: parent
                font.pixelSize: 22
                color: Singletons.Colors.foreground
                font.bold: true
            }
            // SEPARATOR
            Rectangle {
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    margins: {
                        bottom: 10
                    }
                }
                
                height: 20
                width: 1
                color: Singletons.Colors.moduleSeparatorColor
            }
        }
        Rectangle {
            color: 'transparent'
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: 1

            Text {
                id: date
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: Qt.formatDateTime(new Date(), "dd-MM-yyyy");
                anchors.centerIn: parent
                font.pixelSize: 22
                color: Singletons.Colors.foreground
                font.bold: true
            }
        }
        Rectangle {
            color: 'transparent'
            Layout.fillWidth: true
            Layout.fillHeight: true
            Text {
                id: day
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: Qt.formatDateTime(new Date(), "ddd");
                anchors.centerIn: parent
                font.pixelSize: 22
                color: Singletons.Colors.foreground
                font.bold: true
            }
            // SEPARATOR
            Rectangle {
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                    margins: {
                        bottom: 10
                    }
                }
                height: 20
                width: 1
                color: Singletons.Colors.moduleSeparatorColor
            }
        }
    }         
}