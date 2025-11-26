import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami

// Provides basic features needed for all kirigami applications
Kirigami.ApplicationWindow {
    // Unique identifier to reference this object
    id: main

    width: 1200
    height: 800

    // Window title
    // i18nc() makes a string translatable
    // and provides additional context for the translators
    title: i18nc("@title:window", "Smite")

    Component {
        id: userViewComponent
        UserView { userViewModel: globalUserViewModel }
    }
    Component {
        id: libraryViewComponent
        LibraryView { libraryViewModel: globalLibraryViewModel }
    }

    globalDrawer: Kirigami.GlobalDrawer {
        
        actions: [
            Kirigami.Action {
                visible: !globalUserViewModel.isLoggedIn
                text: i18n("Account")
                icon.name: "user-identity"
                onTriggered: {
                    main.pageStack.push(userViewComponent);
                }
            },
            Kirigami.Action {
                text: i18n("Library")
                icon.name: "folder"
                onTriggered: {
                    main.pageStack.push(libraryViewComponent);
                }
            },
            Kirigami.Action {
                visible: globalUserViewModel.isLoggedIn
                text: i18n("Account")
                icon.name: "user-identity"
                onTriggered: {
                    main.pageStack.push(userViewComponent);
                }
            },
            Kirigami.Action {
                text: i18n("Settings")
                icon.name: "settings-configure"
                onTriggered: showPassiveNotification("Settings clicked")
            }
        ]
    }

    pageStack.defaultColumnWidth: Infinity

    // Set the first page that will be loaded when the app opens
    // This can also be set to an id of a Kirigami.Page
    pageStack.initialPage: globalUserViewModel.isLoggedIn ? libraryViewComponent : userViewComponent
}