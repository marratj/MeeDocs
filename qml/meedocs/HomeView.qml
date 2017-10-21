import QtQuick 1.1
import com.nokia.meego 1.1
import MeeDocs 1.0
import "meedocs.js" as Meedocs
import "storage.js" as Storage


Page {

    function refreshList() {
        if (status === PageStatus.Active) {
            docModel.xml = "";
            listBusy.visible = true;
            listBusy.running = true;
            Meedocs.refreshDocList(collectionType, docUrl);
        }
    }

    property string docUrl: ""
    property string collectionType: "docs"
    property string collectionTitle: "My Drive"


    tools: commonTools

    onStatusChanged: refreshList()

    MeeDocs {
        id: meeDocs
        onCollectionCreated: refreshList()
    }

    PageHeader {
        id: pageHeader
        text: collectionTitle
        anchors.top: parent.top
    }

    XmlListModel {
          id: docModel
          query: "/feed/entry"
          namespaceDeclarations: "declare default element namespace 'http://www.w3.org/2005/Atom'; declare namespace gd = 'http://schemas.google.com/g/2005'; declare namespace docs = 'http://schemas.google.com/docs/2007';"
          XmlRole { name: "title"; query: "title/string()" }
          XmlRole { name: "resourceId"; query: "gd:resourceId/string()" }
          XmlRole { name: "doc_description"; query: "docs:description/string()" }
          XmlRole { name: "edit_link"; query: "link[@rel='edit']/@href/string()" }
          XmlRole { name: "self_link"; query: "link[@rel='self']/@href/string()" }
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
                text: title
                description: doc_description
                onClicked: {
                    Meedocs.showDoc(resourceId, title);
                    appWindow.pageStack.push(docView);
                }
                onLongPress: {
                    itemMenu.editLink = edit_link;
                    itemMenu.selfLink = self_link;
                    itemMenu.docTitle = title;
                    itemMenu.resourceId = resourceId;
                    itemMenu.open();
                }
        }
     }

    QueryDialog {
        id: dialog
        acceptButtonText: "Trash it"
        rejectButtonText: "No thanks"
        message: "Do you want to delete "+itemMenu.docTitle+"?";
        title: Text { text: "Delete this file" }
        onAccepted: {
            meeDocs.trashFile(itemMenu.selfLink, Meedocs.returnAccessToken());
        }
    }


    Menu {

        property string editLink: ""
        property string selfLink: ""
        property string docTitle: ""
        property string resourceId: ""

        id: itemMenu
        visualParent: pageStack
        MenuLayout {

            MenuItem {
                text: qsTr("Delete this file")

                onClicked: {
                    dialog.open();
                }
            }
            MenuItem {
                text: qsTr("Add to collection")

                onClicked: {
                    collectionView.addDocId = itemMenu.resourceId;
                    appWindow.pageStack.push(collectionView);
                }
            }


            MenuItem {
                text: qsTr("Remove from this collection")

                onClicked: {
                    meeDocs.removeFromCollection(itemMenu.editLink, Meedocs.returnAccessToken());
                    refreshList();
                }
            }
        }
    }


}
