pragma Singleton

import QtQuick
import QtQuick.Controls as T
import MaterialRally as Rally
import "helper.js" as Helper


/*!
    \qmltype Helper
    \inqmlmodule MaterialRally
    \ingroup qmlclass
    \inherits QtObject

    \brief Singleton with helper functions to create dialogs and items dynamically.

    Helper is a singleton - it is not instantiated, its functions are called directly on the type,
    e.g. \c {Rally.Helper.createDialog(...)}.

    The dialog functions create the dialog as a child of the application's root content item
    (see \l RallyApplicationWindow and \l RallyRootPage), open it right away and destroy it
    again after it has been closed. So a dialog can be shown with a single function call, without
    declaring it anywhere up front.

    \section1 Example

    Showing a Rally \l Dialog defined in its own file \c EditAccountDialog.qml:

    \qml
    // EditAccountDialog.qml
    import QtQuick
    import MaterialRally as Rally

    Rally.Dialog {
        id: dialog

        property string accountName

        title: qsTr("Edit %1").arg(dialog.accountName)
        onBackButtonClicked: dialog.close()

        // ...
    }
    \endqml

    \qml
    // somewhere else
    Rally.Button {
        text: qsTr("Edit")
        onClicked: {
            const dialog = Rally.Helper.createDialog(Qt.resolvedUrl("EditAccountDialog.qml"), {
                "accountName": "Checking"
            })
            dialog.accepted.connect(() => console.log("saved"))
        }
    }
    \endqml

    Showing a short message, and calling a function once the current event has been processed:

    \code
    Rally.Helper.createInfoDialog(qsTr("The account was deleted."))
    Rally.Helper.callDelayed(() => listView.positionViewAtEnd(), 0)
    \endcode

    \note RallyApplicationWindow or RallyRootPage has to be the root item of the application,
    otherwise there is no parent the dialogs can be created in.

    \sa Dialog, InfoDialog
*/
QtObject {


    /*!
      \qmlmethod object Helper::createDialog(url url, object options, real offset)

      Creates the dialog defined by the component at \a url, parents it to the root content
      item of the application and opens it. The dialog is destroyed automatically shortly after
      it has been closed. Pass an absolute \a url, e.g. one returned by \c {Qt.resolvedUrl()} in
      the calling file - a relative url would be resolved relative to the MaterialRally module.

      \a options is an optional map of initial property values, as passed to
      \l [QML] {QtQml::Component::createObject()}{Component.createObject()}.

      \a offset is an optional vertical offset, in pixels, the open animation of a Rally
      \l Dialog starts from (see \l {Dialog::openWithAnimOffset()}{Dialog.openWithAnimOffset()}).
      Other popup types ignore it and are simply opened.

      Returns the created dialog, or \c undefined if the component could not be created
      synchronously (e.g. it failed to load, or is loaded from the network).
    */
    function createDialog(url, options, offset) {

        return Helper.createDialog(url, Rally.RootItem.contentItem, options, offset)
    }


    /*!
      \qmlmethod object Helper::createInfoDialog(string text, real offset)

      Creates and opens an \l InfoDialog showing \a text. The dialog is destroyed automatically
      shortly after the user dismissed it. \a offset is currently not used by InfoDialog.

      Returns the created dialog.
    */
    function createInfoDialog(text, offset) {

        return Helper.createDialog(Qt.resolvedUrl("InfoDialog.qml"), Rally.RootItem.contentItem, {"text": text}, offset)
    }


    /*!
      \qmlmethod object Helper::createItem(url url, Item parent, object options)

      Creates an object from the component at \a url (an absolute url, see createDialog()) as a
      child of \a parent, using \a options as initial property values. Unlike createDialog(), the object is neither opened nor destroyed
      automatically.

      Returns the created object, or \c undefined if the component could not be created
      synchronously. Errors are printed as warnings.

      \code
      const item = Rally.Helper.createItem(Qt.resolvedUrl("AccountCard.qml"), column, {
          "accountName": "Savings"
      })
      \endcode
    */
    function createItem(url, parent, options) {

        return Helper.createItem(url, parent, options)
    }


    /*!
      \qmlmethod void Helper::callDelayed(function functor, int msDelay)

      Calls \a functor once, after \a msDelay milliseconds. If \a msDelay is omitted, the
      function is called as soon as control returns to the event loop.

      \code
      Rally.Helper.callDelayed(() => snackBar.pushMessage(qsTr("Saved")), 500)
      \endcode
    */
    function callDelayed(functor, msDelay) {

        return Helper.callDelayed(functor, msDelay)
    }
}
