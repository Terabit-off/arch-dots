import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

import "../../Singletons" as Singletons 

Rectangle {
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.maximumHeight: 250
    Layout.minimumHeight: 250
    color: Singletons.Colors.moduleBackgroundColor
    border.color: Singletons.Colors.moduleBorderColor
    radius: Singletons.Colors.moduleBorderRadius


    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 4

        RowLayout {
            spacing: 10
            Layout.fillWidth: true

            Text {
                text: "<"
                color: Singletons.Colors.foreground
                font.pixelSize: 18
                Layout.fillWidth: true
                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: currentDate = new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, 1)
                }
            }

            Text {
                text: Qt.formatDate(currentDate, "MMMM yyyy")
                color: Singletons.Colors.foreground
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            Text {
                text: ">"
                color: Singletons.Colors.foreground
                font.pixelSize: 18
                Layout.fillWidth: true
                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: currentDate = new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 1)
                }
            }
        }

        RowLayout {
            spacing: 4
            Layout.fillWidth: true
            Layout.minimumWidth: 230
            Repeater {
                model: ["Mo","Tu","We","Th","Fr","Sa","Su"]
                delegate: Text {
                    text: modelData
                    color: Singletons.Colors.foreground
                    width: 29
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
        

        Grid {
            columns: 7
            spacing: 4

            Repeater {
                model: 42 // 6 weeks

                delegate: Rectangle {
                    width: 29
                    height: 26
                    radius: 6
                    visible: true

                    property int day: {
                        var firstDay = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1)
                        var startOffset = (firstDay.getDay() + 6) % 7 // monday = 0
                        return index - startOffset + 1
                    }

                    color: {
                        var today = new Date()
                        if (day === today.getDate() &&
                            currentDate.getMonth() === today.getMonth() &&
                            currentDate.getFullYear() === today.getFullYear()) {
                            return '#c1666666'
                        }
                        return "transparent"
                    }

                    border.color: "#444"

                    Text {
                        anchors.centerIn: parent
                        text: {
                            var txt = (day > 0 && day <= new Date(currentDate.getFullYear(), currentDate.getMonth()+1, 0).getDate())
                                ? day : ""
                            if(txt === "") {
                                parent.border.color = 'transparent'
                                return ""
                            }
                            parent.border.color = '#444'
                            return txt
                        }
                        color: Singletons.Colors.foreground
                    }
                }
            }
        }
        Item {Layout.fillHeight: true }
    }
    
}