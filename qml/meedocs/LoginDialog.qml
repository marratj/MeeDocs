import QtQuick 1.1
import QtWebKit 1.0
import com.nokia.meego 1.1
// import "meedocs.js" as Meedocs
import "storage.js" as Storage

Page {

    signal finished (string url)

    tools: commonTools


    PageHeader {
        id: pageHeader
        text: "Please login"
        anchors.top: parent.top
    }

    Flickable {
        anchors {
            top: pageHeader.bottom
            topMargin: 0
        }

        width: parent.width
        height: parent.height

        clip: true

        contentWidth: Math.max(parent.width,640)
        contentHeight: Math.max(parent.height,1200)
        pressDelay: 200

        WebView {
            id: webView
            anchors.fill: parent
            preferredHeight: height
            preferredWidth: Math.max(parent.width,640)
            url: "https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=688932937241.apps.googleusercontent.com&redirect_uri=urn:ietf:wg:oauth:2.0:oob&scope=https://docs.google.com/feeds/%20https://spreadsheets.google.com/feeds/%20https://docs.googleusercontent.com/";

            onLoadFinished: {
                loginDialog.finished(webView.title);
            }

        }
    }



}
