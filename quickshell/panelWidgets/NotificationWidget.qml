import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import Quickshell.Services.Notifications
import QtQuick.Controls

import "../Singletons" as Singletons

Rectangle {
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: Singletons.Colors.moduleBackgroundColor
    border.color: Singletons.Colors.moduleBorderColor
    radius: Singletons.Colors.moduleBorderRadius

    NotificationServer {
        id: notifications
        onNotification: (n) => {
            n.tracked = true
        }
    }

    ListView {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        clip: true
        spacing: 5
        anchors.margins: {
            top: 15
            bottom: 15
        }
        model: notifications.trackedNotifications
        
        

        verticalLayoutDirection: ListView.BottomToTop
        delegate: Rectangle {
            width: 370
            height: 70
            color: Singletons.Colors.notifyCardBackground
            radius: 13
            border.color: Singletons.Colors.moduleBorderColor
            anchors.margins: {
                top: 10
                bottom: 10
            }
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
                        source: modelData.image  // берем иконку уведомления
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
    }
}
