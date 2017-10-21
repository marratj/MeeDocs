import QtQuick 1.1
import com.nokia.meego 1.1
import "meedocs.js" as Meedocs
import "storage.js" as Storage

Page {
    tools: commonTools

    onStatusChanged: {
        if (mainPage.status === PageStatus.Activating) {
            if (Storage.getKeyValue("accessToken")) {
                loginButton.visible = false;
                loginLabel.visible = true;
                appWindow.pageStack.replace(Qt.resolvedUrl("HomeView.qml"));
            }
        }
    }

    PageHeader {
        id: pageHeader
        text: "Welcome to MeeDocs"
        anchors.top: parent.top
    }

    Button {
        id: loginButton
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: pageHeader.bottom
            topMargin: 64
        }
        text: qsTr("Please login")
        onClicked: appWindow.pageStack.replace(loginDialog)
    }

    Label {
        id: loginLabel
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Authenticating, please wait!"
        visible: false
    }
}
