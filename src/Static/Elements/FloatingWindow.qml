import QtQuick

Window {
    id: floatWin
    width: 500
    height: 400
    visible: true

    property string tabTitle: ""
    property Item tabContent: null
    signal reattached(string title, Item content)

    title: tabTitle

    // Reparent content item to this window's container
    Item {
        id: container
        anchors.fill: parent

        Component.onCompleted: {
            if (floatWin.tabContent) {
                floatWin.tabContent.parent = container
                floatWin.tabContent.anchors.fill = container
                floatWin.tabContent.visible = true
            }
        }
    }

    // When closed, emit signal to re-dock back into main window
    onClosing: (close) => {
        if (tabContent) {
            tabContent.visible = false
            reattached(tabTitle, tabContent)
        }
    }
}