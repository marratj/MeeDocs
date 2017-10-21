import QtQuick 1.1
import com.nokia.meego 1.1
import com.nokia.extras 1.1
import MeeDocs 1.0
import "meedocs.js" as Meedocs
import "storage.js" as Storage


Page {

    // property string dir_name: "C:/Users/marrat/"
    property string dir_name: "/home/user/MyDocs/"
    property string doc_name: ""
    property int dir_depth: 0

    function refreshDirList(entry) {
        var dirEntry;
        var index = 0;
        while ( meeDocs.listDirContent(entry)[index] ){
            dirEntry = meeDocs.listDirContent(entry)[index];
            if (dirEntry !== "." && dirEntry !== ".."){
                dirContent.append({"name": dirEntry});
            }
            index++;
            // console.log(dirEntry);
        }
    }

    tools: uploadTools

    Component.onCompleted: {

            dirView.visible = false;
            listBusy.visible = true;
            listBusy.running = true;
            refreshDirList(dir_name);
            listBusy.running = false;
            listBusy.visible = false;
            dirView.visible = true;
    }

    MeeDocs {
        id: meeDocs

        onUploadFailed: {
            ib.text = "Your upload failed, please try again!";
            ib.show();
        }

    }

    InfoBanner {
        id: ib
    }

    PageHeader {
        id: pageHeader
        text: "Upload a file"
        anchors.top: parent.top
    }

    ListModel {
        id: dirContent
    }

    ListView {
        id: dirView
        anchors.top: pageHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        model: dirContent
        clip: true

        delegate: ListItemDelegate {

                id: fileType
                Component.onCompleted: {
                    if ( meeDocs.isDir(dir_name+name) ) {
                        fileType.drilldown = true;
                    }
                }

                text: name

                onClicked: {

                    if ( meeDocs.isDir(dir_name+name) ) {
                        appWindow.pageStack.push(Qt.resolvedUrl("UploadView.qml"), {dir_name: dir_name+name+"/"});
                    }
                    else {
                        doc_name = name;
                        dialog.open();
                    }
                }
            }

    }

    BusyIndicator {
        id: listBusy
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        running: true

    }

    QueryDialog {
        id: dialog
        acceptButtonText: "Upload now"
        rejectButtonText: "No thanks"
        message: "Do you want to upload "+doc_name+" to Google Docs? File size is "+meeDocs.uploadFileSize(dir_name, doc_name)+" bytes.";
        title: Text { text: "Upload your file" }
        onAccepted: {
            //Meedocs.uploadDoc(dir_name, doc_name);
            meeDocs.doUpload(dir_name, doc_name, Meedocs.returnAccessToken());

        }
    }

    ToolBarLayout {
        id: uploadTools
        visible: false
        ToolIcon {
            platformIconId: "toolbar-back"
            //anchors.left: (parent === undefined) ? undefined : parent.left
            onClicked: appWindow.pageStack.pop()
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            //anchors.right: (parent === undefined) ? undefined : parent.right
            onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
    }

}
