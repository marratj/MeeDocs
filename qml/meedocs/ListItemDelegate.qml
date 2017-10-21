// import QtQuick 1.0 // to target S60 5th Edition or Maemo 5
import QtQuick 1.1
import com.nokia.meego 1.1

 Item {
    property alias text: mainText.text
    // property alias iconSource: icon.source
    property alias description: subText.text
    // Signal emitted when the delegate is being clicked
    property alias drilldown: browsearrow.visible
    signal clicked
    signal longPress


    id: listItem
    height: 88
    width: parent.width

    BorderImage {
        id: background
        anchors.fill: parent
        // Fill page borders
        // anchors.leftMargin: -listPage.anchors.leftMargin
        // anchors.rightMargin: -listPage.anchors.rightMargin
        visible: mouseArea.pressed
        source: "image://theme/meegotouch-list-background-pressed-center"
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 8

        Image {
            id: statusindicator
            anchors.verticalCenter: parent.verticalCenter
            source: {
                if (drilldown == true){
                    return "image://theme/icon-m-common-directory" + (theme.inverted ? "-inverse" : "");
                }
                else {
                    return "image://theme/icon-m-content-document" + (theme.inverted ? "-inverse" : "");
                }
            }
        }

        Item {
            width: 16
            height: parent.height
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            Label {
                id: mainText
                font.weight: Font.Bold
                font.pixelSize: 26
                width: listItem.width - statusindicator.width - browsearrow.width
            }
            Label {
                id: subText
                font.weight: Font.Light
                font.pixelSize: 22
                color: "#dd4814"
                horizontalAlignment: Text.AlignRight
                wrapMode: Text.WordWrap
            }
        }
    }
    Image {
        id: browsearrow
        source: "image://theme/icon-m-common-drilldown-arrow" + (theme.inverted ? "-inverse" : "")
        anchors.right: parent.right;
        anchors.verticalCenter: parent.verticalCenter
        visible: false
    }
    MouseArea {
        id: mouseArea
        anchors.fill: background
        onClicked: {
            listItem.clicked();
        }
        onPressAndHold: {
           listItem.longPress();
        }
    }
}

