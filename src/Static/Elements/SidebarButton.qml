import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    // Properties
    property string text: ""
    property int tabIndex: -1
    property int currentIndex: -1
    property Item contentItem: null
    property Item holderItem: null

    // Signals
    signal selected(int index)
    signal detachRequested(string title, Item content, Item holder, Item button)

    Layout.fillWidth: true
    implicitHeight: 50
    color: !enabled ? "#d0d0d0": (currentIndex === tabIndex ? "#ffffff" : "transparent")

    Text {
        anchors.centerIn: parent
        text: root.text
    }

    ContextMenu.menu: Menu {
        MenuItem {
            text: "Detatch"
            onTriggered: root.detachRequested(root.text, root.contentItem, root.holderItem, root)
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.selected(root.currentIndex)
    }
}
