import QtQuick 1.1
import com.nokia.meego 1.1
import com.nokia.extras 1.1
import "meedocs.js" as Meedocs
import "storage.js" as Storage


PageStackWindow {
    id: appWindow

    onOrientationChangeFinished: {
        if (appWindow.inPortrait) {
            appWindow.showStatusBar = true;
        } else {
            appWindow.showStatusBar = false;
        }
    }

    initialPage: mainPage


    MainPage {
        id: mainPage
    }

    /* HomeView {
        id: homeView
    } */

    DocView {
        id: docView
    }

/*    UploadView {
        id: uploadView
    } */

    CollectionView {
        id: collectionView
    }

    /* CollectionAdd {
        id: collectionAdd
    } */

    LoginDialog {
        id: loginDialog
        onFinished: {
            if(url.toString().indexOf("code=")>0) {
                var codeStart = url.toString().indexOf("code=");
                var code = url.toString().substring(codeStart + 5);
                Meedocs.getAccessToken(code);
            }
        }
    }

    Dialog {
       width: 400
       id: aboutDialog
       title: Text {
         //height: 2
         //width: parent.width
         text: "MeeDocs"
         font.pointSize: 36
         color: "white"
       }
       content:Item {
         id: name
         height: 300
         width: parent.width
           Text {
               id: topText
               font.pointSize: 18
               anchors.top: parent.top
               width: parent.width
               wrapMode: Text.WordWrap
               color: "white"
               text: "MeeDocs is client for Google Docs / Google Drive."
           }

           Text {
               font.pointSize: 18
               anchors.top: topText.bottom
               anchors.topMargin: 20
               width: parent.width
               wrapMode: Text.WordWrap
               color: "white"
               text: "Created by Marcel D. Juhnke <marcel.juhnke@ovi.com>"
           }
       }
       buttons: ButtonRow {
         style: ButtonStyle { }
           anchors.horizontalCenter: parent.horizontalCenter
           Button {text: "OK"; onClicked: aboutDialog.accept()}
         }
       }

    ToolBarLayout {
        id: commonTools
        visible: true
        ToolIcon {
            platformIconId: "toolbar-directory"
            anchors.left: parent.left
            onClicked: appWindow.pageStack.push(collectionView)
        }

        ToolIcon {
            platformIconId: "toolbar-attachment"
            // anchors.right: menuButton.left // (parent === undefined) ? undefined : parent.right
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: appWindow.pageStack.push(Qt.resolvedUrl("UploadView.qml"))
        }
        ToolIcon {
            id: menuButton
            platformIconId: "toolbar-view-menu"
            anchors.right: (parent === undefined) ? undefined : parent.right
            onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
    }

    ToolBarLayout {
        id: collectionListTools
        visible: false
        ToolIcon {
            platformIconId: "toolbar-back"
            anchors.left: parent.left
            onClicked: {
                appWindow.pageStack.pop();
            }
        }

        ToolIcon {
            platformIconId: "toolbar-view-menu"
            anchors.right: (parent === undefined) ? undefined : parent.right
            onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
    }

    Menu {
        id: myMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem {
                text: qsTr("Authenticate")

                onClicked: {
                    appWindow.pageStack.replace(loginDialog);
                }
            }
            MenuItem {
                text: qsTr("About MeeDocs")

                onClicked: {
                    aboutDialog.open();
                }
            }
        }
    }
}
