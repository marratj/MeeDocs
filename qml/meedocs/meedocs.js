Qt.include("storage.js")

var accessToken;
var refreshToken = getKeyValue("refreshToken");

// This function initiates the OAuth 2.0 AccessToken request
function getAccessToken(code) {
    console.log("getAccessToken() was called.");
    // defining needed variables for Google API
    code = escape(code).replace(/\//g, "%2F");
    var client_id = escape("688932937241.apps.googleusercontent.com");
    var client_secret = escape("MkwxK2cUClP0pTbPD5QqA2bw");
    var redirect_uri = escape("urn:ietf:wg:oauth:2.0:oob");
    var grant_type = escape("authorization_code");
    var url = "https://accounts.google.com/o/oauth2/token";

    doWebRequest("POST", url, "code=" + code + "&client_id=" + client_id + "&client_secret=" + client_secret + "&redirect_uri=" +  redirect_uri + "&grant_type=" + grant_type, parseAccessToken);
}

function refreshAccessToken() {
    console.log("refreshAccessToken() was called.");
    // defining needed variables for Google API
    var client_id = escape("688932937241.apps.googleusercontent.com");
    var client_secret = escape("MkwxK2cUClP0pTbPD5QqA2bw");
    var grant_type = escape("refresh_token");
    console.log(refreshToken);
    var url = "https://accounts.google.com/o/oauth2/token";

    doWebRequest("POST", url, "client_id=" + client_id + "&client_secret=" + client_secret + "&refresh_token=" +  refreshToken + "&grant_type=" + grant_type, parseAccessToken);
}

function returnAccessToken() {
    accessToken = getKeyValue("accessToken");
    return accessToken;
}


// This function does a XMLHttpRequest with the given paramaters and calls $callback() with the content of the server response
function doWebRequest(method, url, params, callback) {
    console.log("doWebRequest() was called.");
    var doc = new XMLHttpRequest();

    doc.open(method, url, true);

    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
            var status = doc.status;
            if(status!=200) {
                console.log("Google API returned " + status + " " + doc.statusText);
                if(status == 400) {
                    setKeyValue("accessToken", "");

                    appWindow.pageStack.replace(mainPage);

                }
                if(status == 401) {
                    setKeyValue("accessToken", "");
                    if (getKeyValue("refreshToken") !== "NULL") {
                        refreshAccessToken();
                    }
                    // console.log("Loading mainPage again");
                    // appWindow.pageStack.replace(mainPage);

                }
            }
        } else if (doc.readyState === XMLHttpRequest.DONE) {
            var data;
            var contentType = doc.getResponseHeader("Content-Type");
            data = doc.responseText;
            console.log("Google API returned " + doc.status + " " + doc.statusText);
            callback(data);
        }
    }

// set needed headers for the Google API

    doc.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");


    // if (callback !== parseAccessToken) {
        doc.setRequestHeader("GData-Version", "3.0");
        doc.setRequestHeader("Authorization", "Bearer " + accessToken);
    // }

    console.log(params);
    doc.send(params);
}

// This function parses the access token from the response URI
function parseAccessToken(response) {
    console.log("parseAccessToken() was called.");
    console.log(response);

    accessToken = parseParameter(response, "access_token");

    // check if refresh token was supplied by response (usually only on new login)
    if (parseParameter(response, "refresh_token")) {
        refreshToken = parseParameter(response, "refresh_token");
        setKeyValue("refreshToken", refreshToken);
    }

    setKeyValue("accessToken", accessToken);
    console.log("Access Token received from Google = " + accessToken);
    console.log("Refresh Token received from Google = " + refreshToken);

    console.log("Clearing pageStack...");
    appWindow.pageStack.clear();
    console.log("Calling mainPage");
    appWindow.pageStack.replace(mainPage);
}

function parseParameter(url, parameter) {
    var parameterIndex = url.indexOf(parameter);
    if(parameterIndex<0) {
        // We didn't find parameter
        console.log("No paramater found!")
        return "";
    }
    var equalIndex = url.indexOf('" : "', parameterIndex);
    if(equalIndex<0) {
        return "";
    }
    var value = "";
    url = url.substring(equalIndex+5);
    var nextIndex = url.indexOf('"');
    if(nextIndex<0) {
        value = url; // .substring(equalIndex+5);
    } else {
        value = url.substring(0, nextIndex);
    }
    return value;
}

// This function gets the Google Docs list and hands the response to returnDocList()
function refreshDocList(type, url) {
    console.log("refreshDocList() was called.");

    if (type === "docs") {
        if (url === "") {
            url = "https://docs.google.com/feeds/default/private/full/folder%3Aroot/contents?showfolders=false&access_token=";
        } else {
            url = url+"?showfolders=false&access_token=";
        }
    } else if (type === "collections") {
            url = "https://docs.google.com/feeds/default/private/full/-/folder?access_token=";
    }

    accessToken = getKeyValue("accessToken");
    doWebRequest("GET", url + accessToken, "", returnDocList);
}

// This function puts the Server document list into the XmlModel of the Doc View
function returnDocList(response) {
    console.log("returnDocList() was called.");
    docModel.xml = response;
    //console.log(response);
    listBusy.running = false;
    listBusy.visible = false;
    docList.visible = true;
}

// This function gets the requested document and hands the response to returnDocList()
function showDoc(doc_id, title) {
    accessToken = getKeyValue("accessToken");
    doWebRequest("GET", "https://docs.google.com/feeds/default/private/full/" + doc_id + "?access_token=" + accessToken, "", returnDoc);
    docView.doc_name = title;
}

// This function puts the info of the requested document to the Doc View
function returnDoc(response) {
    docView.doc_info = response;

    // console.log(response);
}
