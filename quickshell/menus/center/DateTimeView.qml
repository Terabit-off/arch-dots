import QtQuick
import QtQuick.Layouts

import "../../Singletons" as Singletons

Item {
    id: dateTimeRoot

    readonly property var monthNames: [
        "January",
        "February",
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

    readonly property var dayNames: [
        "Sunday",
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday"
    ]

    readonly property var weekDayNames: [
        "Mon",
        "Tue",
        "Wed",
        "Thu",
        "Fri",
        "Sat",
        "Sun"
    ]

    property date currentDate: new Date()
    property int displayedYear: currentDate.getFullYear()
    property int displayedMonth: currentDate.getMonth()

    // These values are shared by all 42 calendar cells instead of being
    // recalculated independently in every delegate.
    property int calendarFirstDay: firstDayOfMonth(displayedYear, displayedMonth)
    property int calendarDays: daysInMonth(displayedYear, displayedMonth)

    function updateTime() {
        currentDate = new Date()
    }

    function refreshCalendarMetrics() {
        calendarFirstDay = firstDayOfMonth(displayedYear, displayedMonth)
        calendarDays = daysInMonth(displayedYear, displayedMonth)
    }

    function monthName(month) {
        return monthNames[month] || ""
    }

    function formatTime(date) {
        var hours = date.getHours().toString().padStart(2, "0")
        var minutes = date.getMinutes().toString().padStart(2, "0")
        var seconds = date.getSeconds().toString().padStart(2, "0")
        return hours + ":" + minutes + ":" + seconds
    }

    function formatDate(date) {
        var day = date.getDate().toString().padStart(2, "0")
        var month = (date.getMonth() + 1).toString().padStart(2, "0")
        var year = date.getFullYear()
        return dayNames[date.getDay()] + ", " + day + "." + month + "." + year
    }

    function isToday(day) {
        return day === currentDate.getDate() &&
            displayedMonth === currentDate.getMonth() &&
            displayedYear === currentDate.getFullYear()
    }

    function daysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate()
    }

    function firstDayOfMonth(year, month) {
        // Monday = 0, Sunday = 6.
        var day = new Date(year, month, 1).getDay()
        return (day + 6) % 7
    }

    function setDisplayedMonth(year, month) {
        var normalized = new Date(year, month, 1)
        displayedYear = normalized.getFullYear()
        displayedMonth = normalized.getMonth()
        refreshCalendarMetrics()
    }

    function previousMonth() {
        setDisplayedMonth(displayedYear, displayedMonth - 1)
    }

    function nextMonth() {
        setDisplayedMonth(displayedYear, displayedMonth + 1)
    }

    function today() {
        var now = new Date()
        currentDate = now
        setDisplayedMonth(now.getFullYear(), now.getMonth())
    }

    Component.onCompleted: refreshCalendarMetrics()

    Timer {
        id: clockTimer

        // Keep the visible seconds accurate without depending on when the
        // timer happened to start.
        interval: Math.max(50, 1000 - (new Date()).getMilliseconds())
        running: true
        repeat: true

        onTriggered: {
            dateTimeRoot.updateTime()
            interval = Math.max(50, 1000 - (new Date()).getMilliseconds())
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

                text: dateTimeRoot.formatTime(dateTimeRoot.currentDate)

                color: Singletons.Colors.foreground
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter

                font.family: Singletons.Colors.uiFont
                font.pixelSize: 36
                font.bold: true
            }

            Text {
                Layout.fillWidth: true

                text: dateTimeRoot.formatDate(dateTimeRoot.currentDate)

                color: todayMouse.containsMouse
                    ? Singletons.Colors.foreground
                    : Singletons.Colors.foregroundDim

                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                opacity: 0.75

                font.family: Singletons.Colors.uiFont
                font.pixelSize: 13

                MouseArea {
                    id: todayMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: dateTimeRoot.today()
                }
            }
        }

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

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: ""
                    color: previousMonthMouse.containsMouse
                        ? Singletons.Colors.foreground
                        : Singletons.Colors.foregroundDim
                    font.family: Singletons.Colors.iconFont
                    font.pixelSize: 14

                    MouseArea {
                        id: previousMonthMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: dateTimeRoot.previousMonth()
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: dateTimeRoot.monthName(dateTimeRoot.displayedMonth)
                        + " " + dateTimeRoot.displayedYear
                    color: Singletons.Colors.foreground
                    font.family: Singletons.Colors.uiFont
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    text: ""
                    color: nextMonthMouse.containsMouse
                        ? Singletons.Colors.foreground
                        : Singletons.Colors.foregroundDim
                    font.family: Singletons.Colors.iconFont
                    font.pixelSize: 14

                    MouseArea {
                        id: nextMonthMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: dateTimeRoot.nextMonth()
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 7
                rowSpacing: 4
                columnSpacing: 2

                Repeater {
                    model: dateTimeRoot.weekDayNames

                    Text {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 15

                        required property string modelData

                        text: modelData
                        color: modelData === "Sat" || modelData === "Sun"
                            ? Singletons.Colors.weekendColor
                            : Singletons.Colors.foregroundDim

                        font.family: Singletons.Colors.uiFont
                        font.pixelSize: 10
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

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

                        readonly property int day:
                            index - dateTimeRoot.calendarFirstDay + 1

                        readonly property bool validDay:
                            day >= 1 && day <= dateTimeRoot.calendarDays

                        readonly property bool today:
                            validDay && dateTimeRoot.isToday(day)

                        color: today
                            ? Singletons.Colors.foregroundDim
                            : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: parent.validDay ? parent.day : ""
                            color: parent.today
                                ? Singletons.Colors.menuBackground
                                : Singletons.Colors.foreground
                            font.family: Singletons.Colors.uiFont
                            font.pixelSize: 11
                            font.bold: parent.today
                            opacity: parent.validDay ? 1 : 0
                        }
                    }
                }
            }
        }
    }
}
