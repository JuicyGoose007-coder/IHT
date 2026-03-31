import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#000000"

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int sessionIndex: session.index

    TextConstants { id: textConstants }

    Connections {
        target: sddm

        function onLoginSucceeded() {
            errorMessage.color = "#42be65"
            errorMessage.text = textConstants.loginSucceeded
        }
        function onLoginFailed() {
            password.text = ""
            errorMessage.color = "#ee5396"
            errorMessage.text = textConstants.loginFailed
            errorShake.start()
        }
        function onInformationMessage(message) {
            errorMessage.color = "#ee5396"
            errorMessage.text = message
        }
    }

    // Subtle grid pattern overlay
    Canvas {
        anchors.fill: parent
        opacity: 0.03
        onPaint: {
            var ctx = getContext("2d")
            ctx.strokeStyle = "#f2f4f8"
            ctx.lineWidth = 0.5
            var step = 40
            for (var x = 0; x < width; x += step) {
                ctx.beginPath()
                ctx.moveTo(x, 0)
                ctx.lineTo(x, height)
                ctx.stroke()
            }
            for (var y = 0; y < height; y += step) {
                ctx.beginPath()
                ctx.moveTo(0, y)
                ctx.lineTo(width, y)
                ctx.stroke()
            }
        }
    }

    // Death kanji - centered, large, background element
    Text {
        id: deathKanji
        text: "\u6B7B"
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -20
        font.pixelSize: 600
        font.weight: Font.Black
        font.bold: true
        color: "#f2f4f8"
        opacity: 0.04
        z: 0
    }

    // Clock - top right
    Text {
        id: timeText
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 40
        color: "#dde1e6"
        font.pixelSize: 14
        font.family: "monospace"
        font.letterSpacing: 2
        opacity: 0.6

        property var now: new Date()

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                parent.now = new Date()
                parent.text = Qt.formatDateTime(parent.now, "HH:mm:ss")
            }
        }

        Component.onCompleted: text = Qt.formatDateTime(now, "HH:mm:ss")
    }

    // Date - below clock
    Text {
        anchors.top: timeText.bottom
        anchors.right: timeText.right
        anchors.topMargin: 4
        color: "#dde1e6"
        font.pixelSize: 11
        font.family: "monospace"
        font.letterSpacing: 2
        opacity: 0.4
        text: Qt.formatDateTime(new Date(), "yyyy.MM.dd")
    }

    // Main login container
    Item {
        id: loginContainer
        anchors.centerIn: parent
        width: 320
        z: 1

        Column {
            id: mainColumn
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            spacing: 0

            // Small death kanji above the form
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "\u6B7B"
                font.pixelSize: 56
                font.weight: Font.Bold
                color: "#ee5396"
                opacity: 0.8

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.4; duration: 3000; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 0.8; duration: 3000; easing.type: Easing.InOutSine }
                }
            }

            Item { width: 1; height: 32 }

            // Username field
            Column {
                width: parent.width
                spacing: 6

                Text {
                    text: "USER"
                    color: "#525252"
                    font.pixelSize: 10
                    font.family: "monospace"
                    font.letterSpacing: 3
                    font.bold: true
                }

                Rectangle {
                    width: parent.width
                    height: 40
                    color: "#262626"
                    radius: 2
                    border.color: name.activeFocus ? "#33b1ff" : "#393939"
                    border.width: 1

                    Behavior on border.color {
                        ColorAnimation { duration: 150 }
                    }

                    TextInput {
                        id: name
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        verticalAlignment: Text.AlignVCenter
                        color: "#f2f4f8"
                        font.pixelSize: 14
                        font.family: "monospace"
                        clip: true
                        text: userModel.lastUser || "juicygoose007"
                        selectionColor: "#33b1ff"
                        selectedTextColor: "#161616"

                        KeyNavigation.backtab: rebootButton
                        KeyNavigation.tab: password

                        Keys.onPressed: function(event) {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, sessionIndex)
                                event.accepted = true
                            }
                        }
                    }
                }
            }

            Item { width: 1; height: 16 }

            // Password field
            Column {
                width: parent.width
                spacing: 6

                Text {
                    text: "PASSWORD"
                    color: "#525252"
                    font.pixelSize: 10
                    font.family: "monospace"
                    font.letterSpacing: 3
                    font.bold: true
                }

                Rectangle {
                    width: parent.width
                    height: 40
                    color: "#262626"
                    radius: 2
                    border.color: password.activeFocus ? "#33b1ff" : "#393939"
                    border.width: 1

                    Behavior on border.color {
                        ColorAnimation { duration: 150 }
                    }

                    TextInput {
                        id: password
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        verticalAlignment: Text.AlignVCenter
                        color: "#f2f4f8"
                        font.pixelSize: 14
                        font.family: "monospace"
                        echoMode: TextInput.Password
                        clip: true
                        selectionColor: "#33b1ff"
                        selectedTextColor: "#161616"

                        KeyNavigation.backtab: name
                        KeyNavigation.tab: session

                        Keys.onPressed: function(event) {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, sessionIndex)
                                event.accepted = true
                            }
                        }
                    }
                }
            }

            Item { width: 1; height: 12 }

            // Error message
            Text {
                id: errorMessage
                anchors.horizontalCenter: parent.horizontalCenter
                text: ""
                color: "#ee5396"
                font.pixelSize: 11
                font.family: "monospace"
                height: 16

                NumberAnimation on x {
                    id: errorShake
                    running: false
                    from: -10; to: 10
                    duration: 50
                    loops: 3
                    onFinished: errorMessage.x = 0
                }
            }

            Item { width: 1; height: 16 }

            // Session selector
            Column {
                width: parent.width
                spacing: 6

                Text {
                    text: "SESSION"
                    color: "#525252"
                    font.pixelSize: 10
                    font.family: "monospace"
                    font.letterSpacing: 3
                    font.bold: true
                }

                ComboBox {
                    id: session
                    width: parent.width
                    height: 30
                    font.pixelSize: 12
                    color: "#262626"
                    borderColor: "#393939"
                    focusColor: "#33b1ff"
                    hoverColor: "#333333"
                    textColor: "#dde1e6"

                    model: sessionModel
                    index: sessionModel.lastIndex

                    KeyNavigation.backtab: password
                    KeyNavigation.tab: loginButton
                }
            }

            Item { width: 1; height: 28 }

            // Login button
            Rectangle {
                id: loginButton
                width: parent.width
                height: 40
                radius: 2
                color: loginMouse.containsMouse ? "#ee5396" : "#393939"

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                Text {
                    anchors.centerIn: parent
                    text: "\u6B7B  ENTER"
                    color: loginMouse.containsMouse ? "#000000" : "#dde1e6"
                    font.pixelSize: 12
                    font.family: "monospace"
                    font.letterSpacing: 4
                    font.bold: true

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                MouseArea {
                    id: loginMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sddm.login(name.text, password.text, sessionIndex)
                }

                KeyNavigation.backtab: session
                KeyNavigation.tab: shutdownButton
                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        sddm.login(name.text, password.text, sessionIndex)
                        event.accepted = true
                    }
                }
            }

            Item { width: 1; height: 40 }

            // Power buttons row
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 32

                Text {
                    id: shutdownButton
                    text: "SHUTDOWN"
                    color: shutdownMouse.containsMouse ? "#ee5396" : "#525252"
                    font.pixelSize: 10
                    font.family: "monospace"
                    font.letterSpacing: 2

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }

                    MouseArea {
                        id: shutdownMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sddm.powerOff()
                    }

                    KeyNavigation.backtab: loginButton
                    KeyNavigation.tab: rebootButton
                }

                Text {
                    color: "#393939"
                    text: "|"
                    font.pixelSize: 10
                    font.family: "monospace"
                }

                Text {
                    id: rebootButton
                    text: "REBOOT"
                    color: rebootMouse.containsMouse ? "#ee5396" : "#525252"
                    font.pixelSize: 10
                    font.family: "monospace"
                    font.letterSpacing: 2

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }

                    MouseArea {
                        id: rebootMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sddm.reboot()
                    }

                    KeyNavigation.backtab: shutdownButton
                    KeyNavigation.tab: name
                }
            }
        }
    }

    // Bottom left hostname
    Text {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 40
        text: sddm.hostName
        color: "#525252"
        font.pixelSize: 11
        font.family: "monospace"
        font.letterSpacing: 2
    }

    // Bottom right session info
    Text {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 40
        text: "SDDM"
        color: "#393939"
        font.pixelSize: 11
        font.family: "monospace"
        font.letterSpacing: 2
    }

    Component.onCompleted: {
        // Always focus password since username is remembered
        password.focus = true
    }
}
