import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
    property color base: "#1e1e2e"
    property color surface: "#313244"
    property color text: "#cdd6f4"
    property color accent: "#89b4fa"

    PanelWindow {
        id: bar
        anchors.top: true
        anchors.left: true
        anchors.right: true
        implicitHeight: 38
        color: base
        exclusiveZone: implicitHeight

        Row {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 8

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "KAIRO"
                color: accent
                font.family: "JetBrains Mono"
                font.bold: true
            }

            Repeater {
                model: 5
                delegate: Rectangle {
                    width: 24
                    height: 22
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 4
                    color: index === 0 ? accent : surface

                    Text {
                        anchors.centerIn: parent
                        text: index + 1
                        color: index === 0 ? base : text
                        font.family: "JetBrains Mono"
                        font.pixelSize: 12
                    }
                }
            }

            Item { width: 1; height: 1 }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Qt.formatDateTime(new Date(), "ddd  dd MMM  HH:mm")
                color: text
                font.family: "JetBrains Mono"
                font.pixelSize: 12
            }
        }
    }
}
