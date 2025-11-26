import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import QtQuick.Effects

Kirigami.Page {
    id: libraryView
    required property var libraryViewModel

    title: "Library"

    actions: [
        Kirigami.Action {
            icon.name: "view-refresh"
            text: qsTr("Refresh Library")
            onTriggered: libraryViewModel.refreshLibrary()
            enabled: !libraryViewModel.isLoading
        }
    ]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: libraryViewModel.errorMessage.length > 0
            type: Kirigami.MessageType.Error
            text: libraryViewModel.errorMessage
        }

        Controls.BusyIndicator {
            Layout.alignment: Qt.AlignHCenter
            running: libraryViewModel.isLoading
            visible: libraryViewModel.isLoading
        }

        // Empty state
        ColumnLayout {
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !libraryViewModel.isLoading && libraryViewModel.games.length === 0
            spacing: Kirigami.Units.largeSpacing

            Kirigami.Icon {
                source: "folder-games-symbolic"
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: Kirigami.Units.iconSizes.huge
                implicitHeight: Kirigami.Units.iconSizes.huge
                opacity: 0.5
            }

            Kirigami.Heading {
                text: qsTr("No Games Found")
                level: 2
                Layout.alignment: Qt.AlignHCenter
            }

            Controls.Label {
                text: qsTr("Log in to see your Epic Games library")
                Layout.alignment: Qt.AlignHCenter
                opacity: 0.7
            }
        }

        // Games grid
        Controls.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !libraryViewModel.isLoading && libraryViewModel.games.length > 0

            GridView {
                id: gamesGrid
                anchors.fill: parent
                cellWidth: 180
                cellHeight: 240
                model: libraryViewModel.games
                
                cacheBuffer: height * 0.5

                delegate: Item {
                    width: gamesGrid.cellWidth
                    height: gamesGrid.cellHeight

                    Item {
                        anchors.fill: parent
                        anchors.margins: Kirigami.Units.smallSpacing

                        // Game card
                        Rectangle {
                            id: gameCard
                            width: 160
                            height: 213
                            anchors.centerIn: parent
                            color: "#1a1a1a"
                            radius: 16
                            clip: true

                            Loader {
                                id: imageLoader
                                anchors.fill: parent
                                anchors.margins: 1
                                asynchronous: true

                                sourceComponent: Item {
                                    anchors.fill: parent

                                    Image {
                                        id: gameImage
                                        anchors.fill: parent
                                        source: modelData.artSquare || modelData.artCover || ""
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        smooth: false
                                        sourceSize.width: 160
                                        sourceSize.height: 213
                                        visible: false
                                    }

                                    // Desaturate when not installed
                                    MultiEffect {
                                        id: imageEffect
                                        anchors.fill: parent
                                        source: gameImage
                                        maskEnabled: true
                                        maskSource: roundedMask
                                        colorization: (modelData.isInstalled === true || coverMouseArea.containsMouse) ? 0 : 1
                                        colorizationColor: "#D8D8D8"
                                    }

                                    // Mask for rounded corners
                                    Item {
                                        id: roundedMask
                                        anchors.fill: parent
                                        layer.enabled: true
                                        visible: false

                                        Rectangle {
                                            anchors.fill: parent
                                            radius: 16
                                            color: "black"
                                        }
                                    }

                                    // Placeholder when image is loading/missing
                                    Rectangle {
                                        anchors.fill: parent
                                        visible: gameImage.status !== Image.Ready
                                        color: "#2a2a2a"
                                        radius: 16

                                        Kirigami.Icon {
                                            anchors.centerIn: parent
                                            source: "games-config-tiles"
                                            implicitWidth: Kirigami.Units.iconSizes.large
                                            implicitHeight: Kirigami.Units.iconSizes.large
                                            opacity: 0.3
                                        }
                                    }
                                }
                            }

                            // Hover overlay with gradient background
                            Rectangle {
                                id: hoverOverlay
                                anchors.fill: parent
                                radius: 16
                                opacity: coverMouseArea.containsMouse ? 1 : 0
                                
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "transparent" }
                                    GradientStop { position: 0.5; color: "#40000000" }
                                    GradientStop { position: 1.0; color: "#CC000000" }
                                }

                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 200
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                // Game title on hover
                                Controls.Label {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    anchors.margins: Kirigami.Units.largeSpacing
                                    text: modelData.title || ""
                                    wrapMode: Text.Wrap
                                    maximumLineCount: 3
                                    elide: Text.ElideRight
                                    horizontalAlignment: Text.AlignLeft
                                    font.pointSize: 11
                                    font.weight: Font.Bold
                                    color: "white"
                                    style: Text.Normal
                                }
                            }

                            // Hover effect
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                id: coverMouseArea
                                
                                onEntered: {
                                    gameCard.scale = 1.05
                                }
                                
                                onExited: {
                                    gameCard.scale = 1.0
                                }
                                
                                onClicked: {
                                    // TODO: Show game details
                                    console.log("Clicked:", modelData.title)
                                }
                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}