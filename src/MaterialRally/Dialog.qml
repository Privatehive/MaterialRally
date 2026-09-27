import QtQuick
import QtQuick.Controls as T
import QtQuick.Controls.Material as T
import MaterialRally


/*!
    \qmltype Dialog
    \inqmlmodule MaterialRally
    \ingroup qmlclass
    \inherits QtQuick.Controls::Dialog

    \brief A modal full-screen dialog with a tool bar, title and actions.

    Rally.Dialog is a modal \l [QML] {QtQuick.Controls::Dialog}{Dialog} that covers the whole
    window, like a page that is pushed on top of the application. When it opens, it grows out of
    the application content while the content behind it shrinks slightly into the background;
    when it closes, the animation is reversed.

    The dialog has a tool bar with
    \list
    \li a back button on the left, which emits \l backButtonClicked(),
    \li the \c title in the center, and
    \li the \l actions on the right. If there is not enough room next to the title, the actions
        are shown as icons only.
    \endlist

    The dialog is not closed automatically when the back button is clicked - handle
    \l backButtonClicked() and call \c close(), \c accept() or \c reject(), e.g. after asking
    the user to discard unsaved changes.

    Setting \l busy shows an indeterminate progress bar below the tool bar and disables the
    dialog. A running \l BusyAction shows a busy indicator on its tool button instead.

    The content of the dialog is kept inside the window's safe area. A \c footer assigned to the
    dialog is moved onto the inner page below the content, e.g. for a row of buttons.

    \note The dialog needs a \l RallyApplicationWindow or \l RallyRootPage as root item of the
    application. The easiest way to show a dialog defined in its own file is
    \l {Helper::createDialog()}{Rally.Helper.createDialog()}, which also destroys it after it has
    been closed.

    \section1 Example

    \qml
    // EditAccountDialog.qml
    import QtQuick
    import QtQuick.Layouts
    import MaterialRally as Rally

    Rally.Dialog {
        id: dialog

        property string accountName

        title: qsTr("Edit account")

        onBackButtonClicked: dialog.reject()

        actions: [
            Rally.BusyAction {
                id: saveAction
                text: qsTr("Save")
                icon.source: "qrc:/icons/content-save.svg"
                onTriggered: {
                    saveAction.busy = true
                    backend.saveAccount(nameField.text, () => {
                        saveAction.busy = false
                        dialog.accept()
                    })
                }
            }
        ]

        Rally.ScrollView {
            anchors.fill: parent

            ColumnLayout {
                width: parent.width

                Rally.TextField {
                    id: nameField
                    Layout.fillWidth: true
                    text: dialog.accountName
                    placeholderText: qsTr("Name")
                }
            }
        }
    }
    \endqml

    \qml
    // Opening the dialog
    Rally.Button {
        text: qsTr("Edit")
        onClicked: {
            const dialog = Rally.Helper.createDialog(Qt.resolvedUrl("EditAccountDialog.qml"),
                                                     {"accountName": "Checking"})
            dialog.accepted.connect(() => snackBar.pushMessage(qsTr("Saved")))
        }
    }
    \endqml

    A dialog can also be declared inline and opened with \c open():

    \code
    Rally.Dialog {
        id: settingsDialog
        title: qsTr("Settings")
        onBackButtonClicked: settingsDialog.close()
        // ...
    }

    Rally.Button {
        text: qsTr("Settings")
        onClicked: settingsDialog.open()
    }
    \endcode

    \sa Helper, InfoDialog, BusyAction
*/
T.Dialog {

    id: control


    /*!
      \qmlproperty bool Dialog::busy
      \default false

      If \c true, an indeterminate progress bar is shown below the tool bar and the whole dialog
      is disabled, e.g. while its data is being loaded or saved.
    */
    property alias busy: progressBar.visible


    /*!
      \qmlsignal Dialog::backButtonClicked()

      This signal is emitted when the back button in the tool bar is clicked. The dialog is not
      closed automatically.
    */
    signal backButtonClicked

    T.Material.elevation: 0
    T.Material.roundedScale: T.Material.NotRounded

    enabled: !busy

    focus: true
    modal: true

    parent: T.Overlay.overlay
    width: parent.width

    margins: 0
    padding: 0


    /*!
      \qmlmethod void Dialog::openWithAnimOffset(real yOffset)

      Opens the dialog like \c open(), but lets the open animation start at the vertical
      position \a yOffset (in pixels from the top of the window) instead of the center of the
      window. Use it to let the dialog grow out of the item that opened it:

      \qml
      Rally.ItemDelegate {
          onClicked: {
              const pos = mapToItem(null, 0, height / 2)
              detailDialog.openWithAnimOffset(pos.y)
          }
      }
      \endqml

      The closing animation shrinks the dialog back to the same position.
    */
    function openWithAnimOffset(yOffset) {

        if (yOffset)
            priv.yAnimOffset = yOffset
        control.open()
    }


    /*!
      \qmlproperty list<BusyAction> Dialog::actions

      The actions shown as tool buttons on the right side of the tool bar. An action is disabled
      and shows a busy indicator while its \l {BusyAction::busy}{busy} property is \c true.

      \code
      actions: [
          Rally.BusyAction {
              text: qsTr("Delete")
              icon.source: "qrc:/icons/delete.svg"
              onTriggered: backend.deleteAccount()
          },
          Rally.BusyAction {
              text: qsTr("Save")
              icon.source: "qrc:/icons/content-save.svg"
              onTriggered: backend.saveAccount()
          }
      ]
      \endcode
    */
    property list<BusyAction> actions


    /*!
      \qmlproperty list<QtObject> Dialog::content

      The content of the dialog. This is the default property, so child items can simply be
      declared inside the Dialog. They are placed on an inner page below the tool bar.
    */
    default property list<QtObject> content: []

    Component.onCompleted: {
        if (control.RootItem.root.SafeArea) {
            control.leftPadding = Qt.binding(() => {
                                                 return control.RootItem.root.SafeArea.margins.left
                                             })
            control.rightPadding = Qt.binding(() => {
                                                  return control.RootItem.root.SafeArea.margins.right
                                              })
            control.bottomPadding = Qt.binding(() => {
                                                   return control.RootItem.root.SafeArea.margins.bottom
                                               })
            control.topPadding = Qt.binding(() => {
                                                return control.RootItem.root.SafeArea.margins.top
                                            })
        }
    }

    onFooterChanged: {
        if (control.footer && content) {
            // reassign footer to RallyRootPage so the SafeArea applies
            const footer = control.footer
            control.footer = null
            content.footer = footer
        }
    }

    onHeaderChanged: {
        if (control.header && content) {
            // reassign header to RallyRootPage so the SafeArea applies
            const header = control.header
            control.header = null
            content.header = header
        }
    }

    contentItem: T.Page {

        id: content

        padding: 0

        contentData: control.content

        background: Item {}

        header: ToolBar {

            T.RoundButton {
                icon.source: "qrc:/icons/material_private/48x48/arrow-left.svg"
                flat: true
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    control.backButtonClicked()
                }
            }

            T.Label {
                id: titleLabel
                anchors.centerIn: parent
                text: control.title
                font.pixelSize: 16
                font.letterSpacing: 1.1
            }

            Row {
                id: titleActions
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: titleActions.x - (titleLabel.x + titleLabel.width) > 10
                Repeater {
                    model: control.actions
                    T.ToolButton {
                        action: control.actions[index]
                        flat: true
                        enabled: !action.busy
                        T.BusyIndicator {
                            width: 40
                            height: 40
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            visible: action.busy
                        }
                    }
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                visible: !titleActions.visible
                Repeater {
                    model: control.actions
                    T.ToolButton {
                        action: control.actions[index]
                        flat: true
                        display: T.AbstractButton.IconOnly
                        enabled: !action.busy
                        T.BusyIndicator {
                            width: 40
                            height: 40
                            anchors.centerIn: parent.contentItem
                            visible: action.busy
                        }
                    }
                }
            }

            T.ProgressBar {
                id: progressBar
                anchors.top: parent.bottom
                width: parent.width
                indeterminate: true

                visible: false

                T.Material.accent: T.Material.iconColor

                Component.onCompleted: {
                    contentItem.implicitHeight = 2
                }

                background: Rectangle {
                    implicitHeight: 2
                    color: T.Material.iconColor
                    opacity: 0.6
                }
            }
        }
    }

    T.Overlay.modal: Item {

        id: modalOverlayRoot

        anchors.fill: parent

        onOpacityChanged: {
            opacity = 1 // prevent the overlay from beeing hidden if dialog is getting closed
        }

        Item {

            id: modalOverlay

            anchors.fill: parent

            // Workaround: The overlay item is created with a delay
            states: [
                State {
                    when: priv.state === "open"
                    name: "open"
                },
                State {
                    when: priv.state === "close"
                    name: "close"
                }
            ]

            transitions: [
                Transition {
                    from: "*"
                    to: "open"
                    ScaleAnimator {
                        target: modalOverlay
                        from: 1
                        to: 0.85
                        duration: 200
                        easing.type: Easing.InQuad
                    }
                },
                Transition {
                    from: "*"
                    to: "close"
                    ScaleAnimator {
                        target: modalOverlay
                        from: 0.85
                        to: 1
                        duration: 250
                        easing.type: Easing.OutQuad
                    }
                }
            ]

            ShaderEffectSource {
                id: mainBlur
                anchors.fill: parent
                live: false
                sourceItem: control.RootItem.contentItem ? control.RootItem.contentItem : null
                hideSource: true
                sourceRect: control.RootItem.contentItem ? mainBlur.mapToItem(control.RootItem.contentItem, 0, 0,
                                                                              width, height) : null
            }
        }
    }

    header: Item {}

    enter: Transition {

        ParallelAnimation {
            ScriptAction {
                script: {
                    priv.state = "open"
                }
            }
            SequentialAnimation {
                PauseAnimation {
                    duration: 100
                }
                NumberAnimation {
                    target: control.contentItem
                    property: "opacity"
                    duration: 400
                    easing.type: Easing.OutQuart
                    from: 0
                    to: 1
                }
            }
            SequentialAnimation {
                PauseAnimation {
                    duration: 100
                }
                NumberAnimation {
                    targets: [control.contentItem, control.contentItem.header, control.contentItem.footer]
                    property: "topPadding"
                    duration: 400
                    from: priv.yStart
                    to: 0
                    easing.type: Easing.OutQuart
                }
            }
            NumberAnimation {
                property: "height"
                duration: 300
                from: 0.0
                to: control.parent.height
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "y"
                duration: 300
                from: priv.yAnimOffset
                to: 0
                easing.type: Easing.OutCubic
            }
            ColorAnimation {
                target: control.background
                property: "color"
                duration: 230
                from: control.T.Material.primaryColor
                to: Qt.lighter(control.T.Material.backgroundColor, 1.2)
                easing.type: Easing.OutCubic
            }
        }
    }

    exit: Transition {
        ParallelAnimation {
            ScriptAction {
                script: {
                    priv.state = "close"
                }
            }
            SequentialAnimation {
                PauseAnimation {
                    duration: 100
                }
                ParallelAnimation {
                    NumberAnimation {
                        property: "height"
                        duration: 300
                        from: control.parent.height
                        to: 0.0
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        property: "y"
                        duration: 300
                        from: 0
                        to: priv.yAnimOffset
                        easing.type: Easing.OutCubic
                    }
                    ColorAnimation {
                        target: control.background
                        property: "color"
                        duration: 230
                        from: Qt.lighter(control.T.Material.backgroundColor, 1.2)
                        to: control.T.Material.backgroundColor
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        property: "opacity"
                        duration: 300
                        from: 1
                        to: 0
                        easing.type: Easing.OutCubic
                    }
                }
            }
            NumberAnimation {
                target: control.contentItem
                property: "opacity"
                duration: 400
                easing.type: Easing.OutQuart
                from: 1
                to: 0
            }
            NumberAnimation {
                targets: [control.contentItem, control.contentItem.header, , control.contentItem.footer]
                property: "topPadding"
                duration: 400
                from: 0
                to: priv.yStart
                easing.type: Easing.OutQuart
            }
        }
    }

    onAboutToShow: {

        control.contentItem.opacity = 0
        if (content) {
            content.topPadding = priv.yStart
            if (content.header && content.header.hasOwnProperty("topPadding"))
                content.header.topPadding = priv.yStart
            if (content.footer && content.footer.hasOwnProperty("topPadding"))
                content.footer.topPadding = priv.yStart
        }
    }

    onOpened: {
        control.height = control.parent.height
        control.height = Qt.binding(function () {
            return control.parent.height
        })
    }

    QtObject {
        id: priv
        readonly property real yStart: 80
        property real yAnimOffset: control.parent.height / 2
        property string state: ""
    }
}
