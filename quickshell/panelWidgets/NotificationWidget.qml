import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import Quickshell.Services.Notifications
import QtQuick.Controls

import "../Singletons" as Singletons

Rectangle {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: Singletons.Colors.moduleBackgroundColor
    border.color: Singletons.Colors.moduleBorderColor
    radius: Singletons.Colors.moduleBorderRadius

    NotificationServer {
        id: notifications
        onNotification: (n) => {
            n.tracked = true
            let last = notifications.trackedNotifications.values.length - 1
            Singletons.Colors.notificationIsRead = false
            Singletons.Colors.notificationCount = notifications.trackedNotifications.values.length + 1
            if (last >= 0){
                Qt.callLater(() => {
                    listView.positionViewAtEnd()
                })
            }
        }
    }
    ColumnLayout {
        id: column
        anchors.fill: parent

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumHeight: 15
            Layout.maximumWidth: 350
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10
            color: 'transparent'

            Text {
                text: "clear"
                color: Singletons.Colors.foreground

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        for(let i = notifications.trackedNotifications.values.length; i > 0; i--){
                            notifications.trackedNotifications.values[0].dismiss()
                        }
                    }
                }
            }
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 5
            Layout.margins: {
                left: 10
            }
            model: notifications.trackedNotifications

            delegate: Rectangle {
                id: itemRect
                width: 370
                height: 70
                color: Singletons.Colors.notifyCardBackground
                radius: 13
                border.color: Singletons.Colors.moduleBorderColor
                


                RowLayout {
                    anchors.fill: parent
                    spacing: 10
                    anchors.margins: {
                        left: 5
                        right: 5
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumWidth: 50
                        color: 'transparent'
                        Image {
                            anchors.fill: parent
                            anchors.margins: 2
                            source: modelData.image
                            fillMode: Image.PreserveAspectFit
                        }
                    }
                    //Separator
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumWidth: 1
                        Layout.maximumHeight: 20
                        color: Singletons.Colors.moduleSeparatorColor

                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: 'transparent'
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4
                            Text {
                                color: Singletons.Colors.foreground
                                font.bold: true
                                elide: Text.ElideRight
                                font.pointSize: 10
                                text: modelData.summary 
                            }
                            Text {
                                width: 280
                                color: Singletons.Colors.foreground
                                font.bold: true
                                elide: Text.ElideRight
                                font.pointSize: 9
                                text: modelData.body 
                            }
                            Text {
                                
                                color: '#6a6a6a'
                                font.bold: true
                                elide: Text.ElideRight
                                font.pointSize: 7
                                text: modelData.appName 
                            }
                        }
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        modelData.dismiss()
                    }
                }
            }


            Behavior on contentY {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }

            add: Transition {
                NumberAnimation { property: "x"; from: 100; duration: 150; easing.type: Easing.OutCubic }
                NumberAnimation {property: "opacity"; to: 1; duration: 150}
            }

            remove: Transition {
                NumberAnimation { property: "x"; to:100; duration: 150; easing.type: Easing.InCubic }
                NumberAnimation { property: "opacity"; to: 0; duration: 150}
            }

            displaced: Transition {
                NumberAnimation { property: "y"; duration: 200; easing.type: Easing.OutCubic}
            }


            ScrollBar.vertical: ScrollBar {
                active: true 
                policy: ScrollBar.AlwaysOn
                width: 6
            }
        }
    }

}

