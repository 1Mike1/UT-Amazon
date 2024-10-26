// Components/NavBar.qml
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3

Item {
    id: navBar
    width: parent.width
    height: 50

    property var webview: null

    Rectangle {
        id: rectangle
        width: parent.width
        height: 50
        color: "white"
        anchors.bottom: parent.bottom
        anchors.top: webview.top

        RowLayout {
            anchors.fill: parent
            spacing: 10
            anchors.horizontalCenter: parent.horizontalCenter

            ButtonItem {
                iconSource: "///assets/back.png" 
                onClicked: {
                    if (webview && webview.canGoBack) {
                        webview.goBack()
                    }
                }
            }

            ButtonItem {
                iconSource: "///assets/next.png"
                onClicked: {
                    if (webview && webview.canGoForward) {
                        webview.goForward()
                    }
                }
            }

            ButtonItem {
                iconSource: "///assets/home.png"
                onClicked: {
                    if (webview) {
                      var homeUrl = webview.url.toString();
                      var endIndex = homeUrl.indexOf("/", homeUrl.indexOf("//") + 2);
                      var baseUrl = endIndex !== -1 ? homeUrl.substring(0, endIndex + 1) : homeUrl;
                      webview.url = baseUrl
                    }
                }
            }

            ButtonItem {
                iconSource: "///assets/cart.png" 
                onClicked: {
                    if (webview) {
                        webview.url = webview.url + "/gp/cart/view.html"
                    }
                }
            }

            ButtonItem {
              iconSource: "///assets/location.png" 
              onClicked: {
                selectedCountry = "India"; // Reset to default country
                appSettings.selectedCountry = selectedCountry; // Update settings
                countryDialog.open(); // Open the dialog again
              }
            }

        }
    }
}
