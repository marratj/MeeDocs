import QtQuick 1.1
import com.nokia.meego 1.1
import com.nokia.extras 1.1
import MeeDocs 1.0
import "meedocs.js" as Meedocs
import "storage.js" as Storage


Page {

    property string doc_info: ""
    property string doc_name: ""
    property string addDocId: ""

    tools: docTools

    MeeDocs {
        id: meeDocs

        onCollectionCreated: appWindow.pageStack.pop()
    }

    XmlListModel {
          id: linkModel
          query: "/entry"
          xml: doc_info
          namespaceDeclarations: "declare default element namespace 'http://www.w3.org/2005/Atom'; declare namespace gd = 'http://schemas.google.com/g/2005'; declare namespace docs = 'http://schemas.google.com/docs/2007';"
          XmlRole { name: "link"; query: "content/@src/string()" }
          XmlRole { name: "doctype"; query: "content/@type/string()" }
          XmlRole { name: "lastModified"; query: "docs:modifiedByMeDate/string()" }
          XmlRole { name: "author"; query: "author/name/string()" }
          XmlRole { name: "description"; query: "docs:description/string()" }
          XmlRole { name: "resourceId"; query: "gd:resourceId/string()" }
          XmlRole { name: "documentType"; query: "category[@scheme='http://schemas.google.com/g/2005#kind']/@label/string()" }
          XmlRole { name: "self_link"; query: "link[@rel='self']/@href/string()" }
          XmlRole { name: "parentCollection1"; query: "link[@rel='http://schemas.google.com/docs/2007#parent'][1]/@href/string()" }
          XmlRole { name: "parentCollection2"; query: "link[@rel='http://schemas.google.com/docs/2007#parent'][2]/@href/string()" }
          XmlRole { name: "parentCollection3"; query: "link[@rel='http://schemas.google.com/docs/2007#parent'][3]/@href/string()" }
          XmlRole { name: "parentCollection4"; query: "link[@rel='http://schemas.google.com/docs/2007#parent'][4]/@href/string()" }
          XmlRole { name: "parentCollection5"; query: "link[@rel='http://schemas.google.com/docs/2007#parent'][5]/@href/string()" }
    }

    PageHeader {
        id: pageHeader
        text: doc_name
        anchors.top: parent.top
    }

    ListView {

        id: docDetails
        anchors.top: pageHeader.bottom
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        model: linkModel
        clip: true
        delegate: Item {

            //anchors.horizontalCenter: parent.horizontalCenter

            Column {
                id: lmText
                anchors.top: parent.top
                anchors.topMargin: 24

                Text {

                    text: "Author:"
                    font.pointSize: 20
                    font.family: "Nokia Pure"
                }
                Text {

                    text: author
                    font.pointSize: 14
                    font.family: "Nokia Pure"
                }
                Text {

                    text: " "
                    font.pointSize: 20
                    font.family: "Nokia Pure"
                }
                Text {

                    text: "Description:"
                    font.pointSize: 20
                    font.family: "Nokia Pure"
                }
                Text {
                    width: docDetails.width - 48
                    wrapMode: Text.WordWrap
                    text: description
                    font.pointSize: 14
                    font.family: "Nokia Pure"
                }
                Text {

                    text: " "
                    font.pointSize: 20
                    font.family: "Nokia Pure"
                }
                Text {

                    text: "Document Type:"
                    font.pointSize: 20
                    font.family: "Nokia Pure"
                }
                Text {
                    width: docDetails.width - 48
                    wrapMode: Text.WordWrap
                    text: documentType
                    font.pointSize: 14
                    font.family: "Nokia Pure"
                }
                Text {

                    text: " "
                    font.pointSize: 20
                    font.family: "Nokia Pure"
                }
                Text {

                    text: "Last Modified:"
                    font.pointSize: 20
                    font.family: "Nokia Pure"
                }
                Text {

                    text: lastModified
                    font.pointSize: 14
                    font.family: "Nokia Pure"
                }
            }

        }
    }

    Sheet {
         id: sheet

         acceptButtonText: "Add"
         rejectButtonText: "Cancel"

         content: Flickable {
             anchors.fill: parent
             anchors.leftMargin: 10
             anchors.topMargin: 10
             contentWidth: col2.width
             contentHeight: col2.height
             flickableDirection: Flickable.VerticalFlick
             Column {
                 id: col2
                 anchors.top: parent.top
                 spacing: 10
                 Button {
                     text: "Click Me!"
                 }
             }
         }
         onAccepted: myButton.text = "Accepted!"
         onRejected: myButton.text = "Rejected!"
     }

    QueryDialog {
        id: dialog
        acceptButtonText: "Trash it"
        rejectButtonText: "No thanks"
        message: "Do you want to move "+doc_name+" to the Trash?";
        title: Text { text: "Move to Trash" }
        onAccepted: {
            meeDocs.trashFile(linkModel.get(0).self_link, Meedocs.returnAccessToken());
        }
    }

    ToolBarLayout {
        id: docTools
        visible: false
        ToolIcon {
            platformIconId: "toolbar-back"
            //anchors.left: (parent === undefined) ? undefined : parent.left
            onClicked: {
                appWindow.pageStack.pop();
            }
        }
        ToolIcon {
            platformIconId: "toolbar-directory"
            //anchors.left: (parent === undefined) ? undefined : parent.left
            onClicked: {
                console.log(doc_info);
                console.log(linkModel.get(0).resourceId);
                collectionView.addDocId = linkModel.get(0).resourceId;
                appWindow.pageStack.push(collectionView);
                console.log(linkModel.get(0).parentCollection1);
                console.log(linkModel.get(0).parentCollection2);
                console.log(linkModel.get(0).parentCollection3);
                console.log(linkModel.get(0).parentCollection4);
                console.log(linkModel.get(0).parentCollection5);
            }
        }
        ToolIcon {
            platformIconId: "toolbar-directory-move-to"
            //anchors.left: (parent === undefined) ? undefined : parent.left
            onClicked: {
                meeDocs.doDownload(linkModel.get(0).link, Meedocs.returnAccessToken(), doc_name, linkModel.get(0).doctype);
                appWindow.pageStack.pop();
            }
        }
        ToolIcon {
            platformIconId: "toolbar-delete"
            //anchors.left: (parent === undefined) ? undefined : parent.left
            onClicked: {
                dialog.open();
            }
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            //anchors.right: (parent === undefined) ? undefined : parent.right
            onClicked: (myMenu.status === DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
    }

}
