import QtQuick 1.1
import com.nokia.meego 1.1


Rectangle {

    property alias text: headerText.text

    width: appWindow.width
    height: 72

    color: "#ffa000"


    Text {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18
        anchors.left: parent.left
        anchors.leftMargin: 18

        id: headerText
        color: "white"

        font.pointSize: 22
        font.family: "Nokia Pure"

    }

}
