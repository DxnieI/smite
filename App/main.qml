import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: smite
    width: 1200
    height: 800
    visible: true
    title: "Smite"
    
    color: "#f5f5f5"
    
    Rectangle {
        anchors.fill: parent
        color: "#ffffff"
        
        Text {
            anchors.centerIn: parent
            text: "Humble beginnings"
            font.pixelSize: 48
            font.weight: Font.Light
            color: "#333333"
        }
    }
}
