import QtQuick 2.0
import QtQuick.Layouts

Rectangle {
    id: root

    Text {
        id: textBox
        anchors.centerIn: parent
        text: "Chasis view"
        color: '#3e1414'
    }

    Connections {
        target: inputManager
        function onActionSignal(status, value) {
            if(status === "move_up") {
                textBox.color = value === true ? '#170e97': "#3e1414"
            }
        }
    }

}