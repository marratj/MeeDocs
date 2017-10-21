import QtQuick 1.1
import com.nokia.meego 1.1
import com.nokia.extras 1.1
import MeeDocs 1.0
import "meedocs.js" as Meedocs
import "storage.js" as Storage


Page {
    tools: collectionTools

    property string addDocId: ""

    onStatusChanged: {
        if (collectionView.status === PageStatus.Active) {
            docModel.xml = "";
            listBusy.visible = true;
            listBusy.running = true;
            Meedocs.refreshDocList("collections", "");
        } else if (collectionView.status === PageStatus.Inactive) {
            docModel.xml = "";
        }

        if (collectionView.addDocId != "") {
            toolbarAddButton.visible = false;
        } else {
            toolbarAddButton.visible = true;
        }
    }

    InfoBanner {
        id: ib
    }

    MeeDocs {
        id: meeDocs

        onCollectionCreated: {
            docModel.xml = "";
            listBusy.visible = true;
            listBusy.running = true;
            Meedocs.refreshDocList("collections", "");
            ib.text = "Collection created!";
            ib.open();
        }
        onCollectionFailed: {
            docModel.xml = "";
            listBusy.visible = true;
            listBusy.running = true;
            Meedocs.refreshDocList("collections", "");
            ib.text = "Creation failed, please try again!";
            ib.open();
        }
    }

    PageHeader {
        id: pageHeader
        text: "My Collections"
        anchors.top: parent.top
    }

    XmlListModel {
          id: docModel
          query: "/feed/entry"
          namespaceDeclarations: "declare default element namespace 'http://www.w3.org/2005/Atom'; declare namespace gd = 'http://schemas.google.com/g/2005'; declare namespace docs = 'http://schemas.google.com/docs/2007';"
          XmlRole { name: "title"; query: "title/string()" }
          XmlRole { name: "collectionUrl"; query: "content/@src/string()" }
          XmlRole { name: "collectionId"; query: "link[@rel='self']/@href/string()" }
          XmlRole { name: "parentCollection"; query: "link[@rel='http://schemas.google.com/docs/2007#parent']/@title/string()" }

    }

    BusyIndicator {
        id: listBusy
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        running: true
    }


    ListView {
        id: docList
        anchors.top: pageHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        model: docModel
        clip: true

        delegate: ListItemDelegate {

                drilldown: true
                text: title
                description: {
                    if (parentCollection !== "") {
                        description = "Subcollection of " + parentCollection
                    }
                }


                onClicked: {
                    if (collectionView.addDocId != "") {
                        meeDocs.addToCollection(collectionUrl, collectionView.addDocId, Meedocs.returnAccessToken());
                        console.log(collectionUrl);
                        console.log(collectionView.addDocId);
                        appWindow.pageStack.replace(Qt.resolvedUrl("HomeView.qml"), {docUrl: collectionUrl, collectionTitle: title, tools: collectionListTools});
                        collectionView.addDocId = "";

                    } else {
                        appWindow.pageStack.push(Qt.resolvedUrl("HomeView.qml"), {docUrl: collectionUrl, collectionTitle: title, tools: collectionListTools} );
                    }
                  }
                onLongPress: {
                    collectionMenu.collectionId = collectionId;
                    collectionMenu.open();
                }
                }
     }

    Sheet {
         id: collectionAdd

         acceptButtonText: "Add"
         rejectButtonText: "Cancel"

         // visualParent: docList

         content:

              Column {
                 id: col2
                 anchors.horizontalCenter: parent.horizontalCenter

                 Label {
                     text: " "
                 }
                 Label {
                     anchors.horizontalCenter: parent.horizontalCenter
                     text: "Give your new collection a name:"
                 }
                 Label {
                     text: " "
                 }

                 TextField {
                     id: collectionTitle
                     width: collectionAdd.width - 40

                     placeholderText: "Collection name"
                 }

            }

         onAccepted: {
             meeDocs.createCollection(collectionTitle.text, Meedocs.returnAccessToken());
             collectionTitle.text = "";
         }
     }

    ToolBarLayout {
        id: collectionTools
        visible: true
        ToolIcon {
            platformIconId: "toolbar-back"
            anchors.left: parent.left
            onClicked: {
                appWindow.pageStack.pop();
                collectionView.addDocId = "";
            }
        }

        ToolIcon {
            id: toolbarAddButton
            platformIconId: "toolbar-add"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: collectionAdd.open();
        }

        ToolIcon {
            id: menuButton
            platformIconId: "toolbar-view-menu"
            anchors.right: (parent === undefined) ? undefined : parent.right
            onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
    }

    Menu {
        property string collectionId: ""

        id: collectionMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem {
                text: qsTr("Delete")

                onClicked: {
                    console.log(collectionMenu.collectionId);
                    meeDocs.deleteCollection(collectionMenu.collectionId, Meedocs.returnAccessToken());
                }
            }
        }
    }

}
