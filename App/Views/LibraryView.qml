import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.Page {
    id: libraryView
    title: "Library"

    // LIBRARY CONTENT
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing

        Kirigami.Heading {
            text: qsTr("Your Library")
            level: 2
        }

        Controls.Label {
            text: qsTr("This is where your library content will be displayed.")
            wrapMode: Text.WordWrap
        }
    }
}