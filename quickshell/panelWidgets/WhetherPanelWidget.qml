import Quickshell.Io
import QtQuick
import Quickshell
import QtQuick.Layouts

import "../Singletons" as Singletons


Rectangle {
    id: weatherRect
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.maximumHeight: 160
    color: Singletons.Colors.moduleBackgroundColor
    border.color: Singletons.Colors.moduleBorderColor
    radius: Singletons.Colors.moduleBorderRadius

    property var weatherIcons: {
        "0": "󰖨",
        "1": "󰖕", "2": "󰖕", "3": "󰖕",
        "45": "󰖑", "48": "󰖑",
        "51": "󰖗", "53": "󰖗", "55": "󰖗",
        "61": "󰖖", "63": "󰖖", "65": "󰖖",
        "71": "󰼶", "73": "󰼶", "75": "󰼶",
        "80": "󰖖", "81": "󰖖", "82": "󰖖",
        "95": "󰖓", "96": "󰖓", "99": "󰖓"
    }

    //current
    property var maxTemp
    property var minTemp
    property var curTemp
    property var humidity
    property var apparentTemp
    property var currentWhetherCode
    property var windSpeed

    //hourly
    property var temps
    property var codes
    property var currentHour: 12

    property alias weatherProcesss: whetherProcess
    Process {
        id: whetherProcess
        //https://api.open-meteo.com/v1/forecast?latitude=44.2233&longitude=42.0578&hourly=temperature_2m,weather_code&forecast_days=2
        command: ["curl", "-s", "https://api.open-meteo.com/v1/forecast?latitude=44.2233&longitude=42.0578&daily=temperature_2m_max,temperature_2m_min&hourly=temperature_2m,weather_code&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m&timezone=Europe%2FMoscow&forecast_days=2"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try{
                    let response = JSON.parse(this.text)
                    //console.log(response)
                    let now = new Date();

                    weatherRect.minTemp = response.daily.temperature_2m_min[0]
                    weatherRect.maxTemp = response.daily.temperature_2m_max[0]
                    weatherRect.humidity = response.current.relative_humidity_2m
                    weatherRect.apparentTemp = response.current.apparent_temperature
                    weatherRect.currentWhetherCode = response.current.weather_code
                    weatherRect.windSpeed = response.current.wind_speed_10m
                    weatherRect.curTemp = response.current.temperature_2m

                    weatherRect.temps = response.hourly.temperature_2m
                    weatherRect.codes = response.hourly.weather_code
                    weatherRect.currentHour = now.getHours()
                    weatherRect.fillWhether()

                    refreshAnimation.running = false

                } catch(e){
                    console.log("ERROR (whether 71): " + e)
                    weatherRect.errorWether()
                }
            }
        }
    }
    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 5
        spacing: 0

        // CURRENT
        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.maximumHeight: 60
            //anchors.bottomMargin: 10
            spacing: 0

            // WHETHER ICON
            Text {
                id: currentWhetherIcon
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumWidth: 80
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                text: "󰖨"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: Singletons.Colors.foreground
                font.pixelSize: 55
                font.bold: true
            }
            // WHETHER TEMP
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 40
                spacing: 1
                Text {
                    id: currentWhetherTemp
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.maximumWidth: 80
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    text: "--"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: Singletons.Colors.foreground
                    font.pixelSize: 18
                    font.bold: true
                }
                Text {
                    id: currentHourText
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.maximumWidth: 10
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    text: "--:--"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: Singletons.Colors.foreground
                    font.pixelSize: 13
                    font.bold: true
                }

            }
            //SEPARATOR
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 20
                Layout.maximumWidth: 1
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.topMargin: 10
                color: Singletons.Colors.moduleSeparatorColor
            }
            //CURRENT INFO
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                //Layout.maximumWidth: 180
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                color: 'transparent'
                RowLayout {
                    anchors {
                        centerIn: parent
                        fill: parent
                        margins: {
                            left: 15
                        }
                    }
                    // FEELS LIKE
                    Text {
                        id: feelsLike
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumWidth: 10
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        text: "feels\n--°"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: Singletons.Colors.foreground
                        font.pixelSize: 11
                        font.bold: true
                    }
                    //SEPARATOR
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumHeight: 20
                        Layout.maximumWidth: 1
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        color: Singletons.Colors.moduleSeparatorColor
                    }
                    // min/max temp
                    Text {
                        id: minMaxTempText
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumWidth: 10
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        text: "--°\n--°"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: Singletons.Colors.foreground
                        font.pixelSize: 11
                        font.bold: true
                    }
                    
                    //SEPARATOR
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumHeight: 20
                        Layout.maximumWidth: 1
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        color: Singletons.Colors.moduleSeparatorColor
                    }
                    // WIND AND HUMIDITY
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumWidth: 10
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        Text {
                            id: windSpeedText
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.maximumWidth: 80
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            text: "--"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: Singletons.Colors.foreground
                            font.pixelSize: 11
                            font.bold: true
                        }
                        Text {
                            id: humidityText
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.maximumWidth: 80
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            text: "--"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: Singletons.Colors.foreground
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }

                    // UPDATE BUTTON
                    Text {
                        id: refreshButton
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumWidth: 5
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        text: ""
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: Singletons.Colors.foreground
                        font.pixelSize: 16
                        font.bold: true


                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                whetherProcess.running = true
                                refreshAnimation.running = true

                            }
                        }
                        transformOrigin: Item.Center

                        RotationAnimator {
                            id: refreshAnimation
                            target: refreshButton
                            from: 0
                            to: 360
                            duration: 1000
                            loops: Animation.Infinite
                        }
                    }
                }
            }
            
        }
        //SEPARATOR
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: 1
            Layout.maximumWidth: 150
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            //Layout.topMargin: 10
            color: Singletons.Colors.moduleSeparatorColor
        }
        // FUTURE WHETHER
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumHeight: 40

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: 'transparent'

                ColumnLayout {
                    anchors.fill: parent
                    //Layout.maximumHeight: 30
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.maximumWidth: 60

                        Text {
                            id: whetherIcon1
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            text: "󰖨"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: Singletons.Colors.foreground
                            font.pixelSize: 20
                            font.bold: true
                        }
                        // WHETHER TEMP
                        Text {
                            id: whetherTemp1
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            text: "--"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: Singletons.Colors.foreground
                            font.pixelSize: 14
                            font.bold: true
                        }
                    }
                    Text {
                        id: whetherTime1
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        text: '--:--'
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: Singletons.Colors.foreground
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
            }
            // SEPARATOR
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 20
                Layout.maximumWidth: 1
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                color: Singletons.Colors.moduleSeparatorColor
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: 'transparent'

                ColumnLayout {
                    anchors.fill: parent
                    Layout.maximumHeight: 30
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.maximumWidth: 60

                        Text {
                            id: whetherIcon2
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            text: "󰖨"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: Singletons.Colors.foreground
                            font.pixelSize: 20
                            font.bold: true
                        }
                        // WHETHER TEMP
                        Text {
                            id: whetherTemp2
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            text: "--"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: Singletons.Colors.foreground
                            font.pixelSize: 14
                            font.bold: true
                        }
                    }
                    Text {
                        id: whetherTime2
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        text: '--:--'
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: Singletons.Colors.foreground
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
            }
            // SEPARATOR
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 20
                Layout.maximumWidth: 1
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                color: Singletons.Colors.moduleSeparatorColor
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: 'transparent'

                ColumnLayout {
                    anchors.fill: parent
                    Layout.maximumHeight: 30
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.maximumWidth: 60

                        Text {
                            id: whetherIcon3
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            text: "󰖨"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: Singletons.Colors.foreground
                            font.pixelSize: 20
                            font.bold: true
                        }
                        // WHETHER TEMP
                        Text {
                            id: whetherTemp3
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            text: "--"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: Singletons.Colors.foreground
                            font.pixelSize: 14
                            font.bold: true
                        }
                    }
                    Text {
                        id: whetherTime3
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        text: '--:--'
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: Singletons.Colors.foreground
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
            }
            // SEPARATOR
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 20
                Layout.maximumWidth: 1
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                color: Singletons.Colors.moduleSeparatorColor
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: 'transparent'

                ColumnLayout {
                    anchors.fill: parent
                    Layout.maximumHeight: 30
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.maximumWidth: 60

                        Text {
                            id: whetherIcon4
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            text: "󰖨"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: Singletons.Colors.foreground
                            font.pixelSize: 20
                            font.bold: true
                        }
                        // WHETHER TEMP
                        Text {
                            id: whetherTemp4
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                            text: "--"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: Singletons.Colors.foreground
                            font.pixelSize: 14
                            font.bold: true
                        }
                    }
                    Text {
                        id: whetherTime4
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        text: '--:--'
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: Singletons.Colors.foreground
                        font.pixelSize: 12
                        font.bold: true
                    }
                }
            }
        }
    }
    function errorWether(){
        currentWhetherTemp.text = "ERROR"
    }
    function fillWhether(){
        currentWhetherIcon.text = weatherRect.weatherIcons[currentWhetherCode] + ""
        currentWhetherTemp.text = weatherRect.curTemp + "°"
        currentHourText.text = weatherRect.currentHour + ":00"
        minMaxTempText.text = maxTemp + "°\n" + minTemp + "°"
        windSpeedText.text = "  " + (windSpeed / 3.6, 2).toFixed(1)
        humidityText.text = "  " + humidity
        feelsLike.text = "feels\n" + apparentTemp + "°"





        whetherIcon1.text = weatherRect.weatherIcons[weatherRect.codes[weatherRect.currentHour + 1]]
        whetherIcon2.text = weatherRect.weatherIcons[weatherRect.codes[weatherRect.currentHour + 2]]
        whetherIcon3.text = weatherRect.weatherIcons[weatherRect.codes[weatherRect.currentHour + 3]]
        whetherIcon4.text = weatherRect.weatherIcons[weatherRect.codes[weatherRect.currentHour + 4]]

        whetherTemp1.text = weatherRect.temps[weatherRect.currentHour + 1] + "°"
        whetherTemp2.text = weatherRect.temps[weatherRect.currentHour + 2] + "°"
        whetherTemp3.text = weatherRect.temps[weatherRect.currentHour + 3] + "°"
        whetherTemp4.text = weatherRect.temps[weatherRect.currentHour + 4] + "°"

        whetherTime1.text = is24(weatherRect.currentHour + 1) + ":00"
        whetherTime2.text = is24(weatherRect.currentHour + 2) + ":00"
        whetherTime3.text = is24(weatherRect.currentHour + 3) + ":00"
        whetherTime4.text = is24(weatherRect.currentHour + 4) + ":00"

        //whetherUpdate.visible = false
    }
    function is24(n){
        if(n >= 24) return n - 24
        return n
    }
}