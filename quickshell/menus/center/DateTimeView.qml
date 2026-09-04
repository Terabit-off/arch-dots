import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../../Singletons" as Singletons

Item {
    id: dateTimeRoot

    property date currentDate: new Date()

    property int displayedYear: currentDate.getFullYear()
    property int displayedMonth: currentDate.getMonth()

    function updateTime() {
        currentDate = new Date()
    }

    function monthName(month) {
        const months = [
            "January",
            "Fedruary",
            "March",
            "April",
            "May",
            "June",
            "July",
            "August",
            "September",
            "October",
            "November",
            "December"
        ]

        return months[month]
    }

    function formatTime(date) {
        const hours = date.getHours().toString().padStart(2, "0")
        const minutes = date.getMinutes().toString().padStart(2, "0")
        const seconds = date.getSeconds().toString().padStart(2, "0")

        return `${hours}:${minutes}:${seconds}`
    }

    function formatDate(date) {
        const days = [
            "Sunday",
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday"
        ]

        const day = date.getDate().toString().padStart(2, "0")
        const month = (date.getMonth() + 1).toString().padStart(2, "0")
        const year = date.getFullYear()

        return `${days[date.getDay()]}, ${day}.${month}.${year}`
    }

    function isToday(day) {
        return day === currentDate.getDate()
            && displayedMonth === currentDate.getMonth()
            && displayedYear === currentDate.getFullYear()
    }

    function daysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate()
    }

    function firstDayOfMonth(year, month) {
        // Понедельник = 0, воскресенье = 6
        const day = new Date(year, month, 1).getDay()

        return (day + 6) % 7
    }

    function previousMonth() {
        if (displayedMonth === 0) {
            displayedMonth = 11
            displayedYear--
        } else {
            displayedMonth--
        }
    }

    function nextMonth() {
        if (displayedMonth === 11) {
            displayedMonth = 0
            displayedYear++
        } else {
            displayedMonth++
        }
    }

    function today() {
        const now = new Date()

        displayedYear = now.getFullYear()
        displayedMonth = now.getMonth()
        currentDate = now
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            dateTimeRoot.updateTime()
        }
    }

    RowLayout {
        anchors {
            fill: parent
            leftMargin: 18
            rightMargin: 18
            topMargin: 16
            bottomMargin: 16
        }

        spacing: 24

        // TIME
        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true

            Layout.alignment: Qt.AlignVCenter

            spacing: 8

            Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 190

                text: dateTimeRoot.formatTime(
                    dateTimeRoot.currentDate
                )

                color: Singletons.Colors.foreground
                verticalAlignment: Text.AlignVCenter

                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 36
                font.bold: true

                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                Layout.fillWidth: true

                text: dateTimeRoot.formatDate(
                    dateTimeRoot.currentDate
                )

                color: Singletons.Colors.foreground
                verticalAlignment: Text.AlignVCenter

                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13

                opacity: 0.75

                horizontalAlignment: Text.AlignHCenter
            }

            Item {
                //Layout.fillHeight: true
            }

            Text {
                Layout.fillWidth: true

                text: dateTimeRoot.displayedMonth !== dateTimeRoot.currentDate.getMonth() || dateTimeRoot.displayedYear !== dateTimeRoot.currentDate.getFullYear() 
                    ? "Today" : ""

                color: todayMouse.containsMouse ? Singletons.Colors.foreground : Singletons.Colors.foregroundDim

                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11

                horizontalAlignment: Text.AlignHCenter

                MouseArea {
                    id: todayMouse
                    anchors.fill: parent
                    hoverEnabled: true

                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        dateTimeRoot.today()
                    }
                }
            }
        }

        // Separator
        Rectangle {
            width: 1
            height: 150
            Layout.alignment: Qt.AlignVCenter

            color: Singletons.Colors.separatorColor
        }

        // CALENDAR
        ColumnLayout {
            Layout.fillHeight: true
            Layout.preferredWidth: 280

            spacing: 5

            // MONTH HEADER
            RowLayout {
                Layout.fillWidth: true

                spacing: 8

                Text {
                    text: ""

                    color: previousMonthMouse.containsMouse
                        ? Singletons.Colors.foreground
                        : Singletons.Colors.foregroundDim

                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14

                    MouseArea {
                        id: previousMonthMouse

                        anchors.fill: parent

                        hoverEnabled: true

                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            dateTimeRoot.previousMonth()
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true

                    text:
                        dateTimeRoot.monthName(
                            dateTimeRoot.displayedMonth
                        )
                        + " "
                        + dateTimeRoot.displayedYear

                    color: Singletons.Colors.foreground

                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    font.bold: true

                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    text: ""

                    color: nextMonthMouse.containsMouse
                        ? Singletons.Colors.foreground
                        : Singletons.Colors.foregroundDim

                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14

                    MouseArea {
                        id: nextMonthMouse

                        anchors.fill: parent

                        hoverEnabled: true

                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            dateTimeRoot.nextMonth()
                        }
                    }
                }
            }

            // WEEK DAYS
            GridLayout {
                Layout.fillWidth: true

                columns: 7

                rowSpacing: 4
                columnSpacing: 2

                Repeater {
                    model: [
                        "Mon",
                        "Tue",
                        "Wed",
                        "Thu",
                        "Fri",
                        "Sat",
                        "Sun"
                    ]

                    Text {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 15

                        required property string modelData

                        text: modelData

                        color: modelData == "Sat" || modelData == "Sun" ? '#ffd6d6' : Singletons.Colors.foregroundDim

                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 10
                        font.bold: true

                        horizontalAlignment:
                            Text.AlignHCenter
                    }
                }
            }

            // DAYS
            GridLayout {
                id: calendarGrid

                Layout.fillWidth: true
                Layout.fillHeight: true

                columns: 7

                rowSpacing: 3
                columnSpacing: 3

                Repeater {
                    model: 42

                    Rectangle {
                        required property int index

                        Layout.fillWidth: true
                        Layout.preferredHeight: 20

                        radius: 7

                        readonly property int firstDay:
                            dateTimeRoot.firstDayOfMonth(
                                dateTimeRoot.displayedYear,
                                dateTimeRoot.displayedMonth
                            )

                        readonly property int days:
                            dateTimeRoot.daysInMonth(
                                dateTimeRoot.displayedYear,
                                dateTimeRoot.displayedMonth
                            )

                        readonly property int day:
                            index - firstDay + 1

                        readonly property bool validDay:
                            day >= 1 && day <= days

                        readonly property bool today:
                            validDay &&
                            dateTimeRoot.isToday(day)

                        color: today
                            ? Singletons.Colors.foregroundDim
                            : "transparent"

                        Text {
                            anchors.centerIn: parent

                            text: parent.validDay
                                ? parent.day
                                : ""

                            color: parent.today
                                ? Singletons.Colors.menuBackground
                                : Singletons.Colors.foreground

                            font.family:
                                "JetBrainsMono Nerd Font"

                            font.pixelSize: 11

                            font.bold:
                                parent.today

                            opacity:
                                parent.validDay ? 1 : 0
                        }
                    }
                }
            }
        }
    }
}