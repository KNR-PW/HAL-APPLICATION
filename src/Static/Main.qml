import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material 2.1

import "Elements" as Elements
import "Pages" as Pages

ApplicationWindow {
    id: mainWindow
    width: 700
    height: 450
    visible: true

    Component {
        id: floatWinComponent
        Elements.FloatingWindow {}
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Elements.TitleBar {}

        RowLayout {
            spacing: 0

            // Sidebar
            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: 100
                color: "#e8e8e8"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: 0
                    spacing: 0

                    Elements.SidebarButton {
                        text: "Chasis"
                        tabIndex: 0
                        currentIndex: stackLayout.currentIndex
                        contentItem: chasisView
                        holderItem: chasisHolder

                        onSelected: (idx) => stackLayout.currentIndex = tabIndex
                        onDetachRequested: (title, content, holder, button) => mainWindow.detachTab(title, content, holder, button)
                    }

                    Elements.SidebarButton {
                        text: "Manipulator"
                        tabIndex: 1
                        currentIndex: stackLayout.currentIndex
                        contentItem: manipulatorView
                        holderItem: manipulatorHolder

                        onSelected: (idx) => stackLayout.currentIndex = tabIndex
                        onDetachRequested: (title, content, holder, button) => mainWindow.detachTab(title, content, holder, button)
                    }

                    Elements.SidebarButton {
                        text: "Telemetry"
                        tabIndex: 2
                        currentIndex: stackLayout.currentIndex
                        holderItem: telemetryHolder

                        onSelected: (idx) => stackLayout.currentIndex = tabIndex
                        onDetachRequested: (title, content, holder, button) => mainWindow.detachTab(title, content, holder, button)
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }

            // Main Content Area
            StackLayout {
                id: stackLayout
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: 0

                Item {
                    id: chasisHolder
                    Pages.Chasis {
                        id: chasisView 
                        anchors.fill: parent
                    }
                }

                Item {
                    id: manipulatorHolder
                    Pages.Manipulator {
                        id: manipulatorView
                        anchors.fill: parent

                    }
                }

                Item {
                    id: telemetryHolder
                    Pages.Telemetry {
                        id: telemetryView
                        anchors.fill: parent
                    }
                }
            }
        }
    }

    function detachTab(title, contentItem, holderItem, tabButton) {
        tabButton.enabled = false
        if (tabButton.tabIndex === stackLayout.currentIndex) stackLayout.currentIndex = -1

        var floatWin = floatWinComponent.createObject(mainWindow, {
            tabTitle: title,
            tabContent: contentItem,
        })

        // Re-dock when floating window is closed
        floatWin.reattached.connect(function(t, content) {
            content.parent = holderItem
            content.anchors.fill = holderItem
            content.visible = true
            if (stackLayout.currentIndex === -1) stackLayout.currentIndex = tabButton.tabIndex
            tabButton.enabled = true
            floatWin.destroy()
        })
    }
}