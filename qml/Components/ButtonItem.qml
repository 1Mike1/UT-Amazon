// Components/ButtonItem.qml
import QtQuick 2.12
import QtQuick.Controls 2.12

Rectangle {
    id: button
    width: 70
    height: 40
    color: "transparent" // Background color
    radius: 5

    property alias iconSource: icon.source  // Property to set icon source

    Image {
        id: icon
        anchors.centerIn: parent
        width: 20  // Adjust the size as needed
        height: 20  // Adjust the size as needed
        fillMode: Image.PreserveAspectFit
    }

    MouseArea {
        anchors.fill: parent
        onClicked: button.clicked()
    }

    signal clicked()  // Signal emitted on click
}
