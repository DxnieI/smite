import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import QtWebEngine

Kirigami.Page {
    id: userView
    required property var userViewModel

    title: userViewModel.isLoggedIn ? "User Profile" : "Login"

    // LOG IN / LOG OUT OPTIONS
    ColumnLayout {
        anchors.centerIn: parent
        spacing: Kirigami.Units.largeSpacing
        width: Math.min(parent.width * 0.8, Kirigami.Units.gridUnit * 30)

        // Kirigami.Heading {
        //     text: qsTr("Choose a login method")
        //     level: 2
        //     Layout.alignment: Qt.AlignHCenter
        // }

        Rectangle {
            Layout.fillWidth: true
            color: "#0f1112"
            radius: 16
            border.color: "#222428"
            border.width: 1
            Layout.preferredHeight: (Kirigami.Units.gridUnit * 8) + (Kirigami.Units.largeSpacing * 2)
            anchors.horizontalCenter: parent.horizontalCenter
            visible: !userViewModel.isLoggedIn

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: Kirigami.Units.largeSpacing

                // EPIC GAMES LOGIN (original content kept)
                Rectangle {
                    Layout.fillWidth: true
                    color: "#2a2a2a"
                    Layout.preferredHeight: 60
                    radius: 12

                    RowLayout {
                        anchors.fill: parent
                        spacing: 12

                        Controls.Label {
                            text: qsTr("EPIC GAMES LOGIN")
                            color: "#ffffff"
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                            font.pointSize: 10
                        }

                        Rectangle {
                            width: 67
                            color: "#ffffff"
                            radius: 12
                            bottomLeftRadius: 0
                            topLeftRadius: 0
                            Layout.preferredHeight: 57
                            Image {
                                source: "qrc:/icons/epic.svg"
                                anchors.centerIn: parent
                                width: 50
                                height: 50
                                fillMode: Image.PreserveAspectFit
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: false
                        onClicked: pageStack.push(epicLoginPage)
                    }
                }

                // EPIC ALTERNATIVE LOGIN (original content kept)
                Rectangle {
                    Layout.fillWidth: true
                    color: "#2a2a2a"
                    Layout.preferredHeight: 60
                    radius: 12

                    RowLayout {
                        anchors.fill: parent
                        spacing: 12

                        Controls.Label {
                            text: qsTr("EPIC ALTERNATIVE LOGIN")
                            color: "#ffffff"
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.bold: true
                            font.pointSize: 10
                        }

                        Rectangle {
                            width: 67
                            color: "#ffffff"
                            radius: 12
                            bottomLeftRadius: 0
                            topLeftRadius: 0
                            Layout.preferredHeight: 57
                            Image {
                                source: "qrc:/icons/epic.svg"
                                anchors.centerIn: parent
                                width: 50
                                height: 50
                                fillMode: Image.PreserveAspectFit
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: false
                        onClicked: {
                            loginDialog.open();
                            userViewModel.clearErrorMessage();
                        }
                    }
                }

                // ADD GOG (AND NILE?) HERE
            }
        }


        // LOGGED IN PAGE
        ColumnLayout {
            Layout.fillWidth: true
            visible: userViewModel.isLoggedIn
            spacing: Kirigami.Units.largeSpacing

            Kirigami.Heading {
                text: "Welcome, " + userViewModel.displayName
                level: 2
                Layout.alignment: Qt.AlignHCenter
            }

            Controls.Button {
                text: "Log Out"
                Layout.fillWidth: true
                onClicked: userViewModel.logout()
            }
        }
    }

    //EPIC LOGIN WEBVIEW PAGE
    Component {
        id: epicLoginPage

        Kirigami.Page {
            id: epicPage

            actions: [
                Kirigami.Action {
                    icon.name: "go-previous"
                    onTriggered: pageStack.pop()
                }
            ]

            WebEngineView {
                id: epicWebView
                anchors.fill: parent
                url: "https://legendary.gl/epiclogin"
            }
        }
    }

    // ALT EPIC LOGIN PAGE
    Controls.Dialog {
        id: loginDialog
        modal: true
        standardButtons: Controls.DialogButtonBox.NoButton

        width: Math.min(userView.width * 0.95, Kirigami.Units.gridUnit * 40)
        height: Math.min(userView.height * 0.9, dialogContent.implicitHeight + (loginFooter ? loginFooter.implicitHeight : 0) + 40)

        onAccepted: {
            userViewModel.login(authCodeField.text);
        }
        
        onRejected: {
            loginDialog.close();
            authCodeField.text = "";
        }

        Connections {
            target: userViewModel
            function onIsLoggedInChanged() {
                if (userViewModel.isLoggedIn) {
                    loginDialog.close();
                    authCodeField.text = "";
                }
            }
        }

        ColumnLayout {
            id: dialogContent
            anchors.centerIn: parent
            spacing: Kirigami.Units.largeSpacing
            width: Math.min(parent.width * 1, Kirigami.Units.gridUnit * 40)

            Kirigami.Heading {
                text: qsTr("Enter Authorization Code!")
                level: 2
                Layout.alignment: Qt.AlignHCenter
            }

            Controls.Label {
                text: qsTr("In order to log in and install your games, you first need to follow the steps below:")
                wrapMode: Text.WordWrap
            }

            Controls.Label {
                text: "1. Open the Epic Website here: "
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Controls.TextField {
                    id: epicLink
                    Layout.fillWidth: true
                    text: "https://legendary.gl/epiclogin"
                    readOnly: true
                    hoverEnabled: false
                    activeFocusOnPress: false
                }

                Controls.Button {
                    text: "Copy"
                    icon.name: "edit-copy"
                    onClicked: {
                        userViewModel.copyToClipboard(epicLink.text);
                    }
                }

                Controls.Button {
                    text: "Open Link"
                    icon.name: "internet-web-browser"
                    onClicked: Qt.openUrlExternally("https://legendary.gl/epiclogin")
                }
            }

            Controls.Label {
                text: "2. Paste your authorization code number in the input box below and click on the login button."
            }

            Controls.TextField {
                id: authCodeField
                Layout.fillWidth: true
                placeholderText: "Enter authorization code"
                enabled: !userViewModel.isLoading
            }

            Controls.BusyIndicator {
                Layout.alignment: Qt.AlignHCenter
                running: userViewModel.isLoading
                visible: userViewModel.isLoading
            }

            Kirigami.InlineMessage {
                Layout.fillWidth: true
                visible: userViewModel.errorMessage.length > 0
                type: Kirigami.MessageType.Error
                text: userViewModel.errorMessage
            }
        }

        footer: RowLayout {
            id: loginFooter
            Controls.Button {
                text: "Log In"
                enabled: authCodeField.text.length > 30
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    userViewModel.login(authCodeField.text);
                }
            }
        }
    }
}
