/*
 * Copyright (C) 2024  Mithlesh Kumar
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * ut-amazon is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import Lomiri.Components 1.3
import "Components"
import Morph.Web 0.1
import QtWebEngine 1.11
import QtSystemInfo 5.5
import Qt.labs.settings 1.0

import Example 1.0

ApplicationWindow {
    id: window
    visible: true
    color: "transparent"

    ScreenSaver {
        id: screenSaver
        screenSaverEnabled: !Qt.application.active || !webview.recentlyAudible
    }

    width: units.gu(45)
    height: units.gu(75)

    objectName: "mainView"
    property bool loaded: false
    property bool onError: false
    property string selectedCountry: "India"  // Default selection
    property var settings: Settings { // Access to settings
        id: appSettings
        property string selectedCountry: "India"  // Default value
    }

    property QtObject defaultProfile: WebEngineProfile {
        id: webContext
        storageName: "myProfile"
        offTheRecord: false
        persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
        property alias dataPath: webContext.persistentStoragePath

        dataPath: dataLocation

        userScripts: [
            WebEngineScript {
                id: cssinjection
                injectionPoint: WebEngineScript.DocumentReady
                worldId: WebEngineScript.UserWorld
                sourceCode: "\n(function() { ... })();"
            }
        ]

        httpUserAgent: "Mozilla/5.0 (Linux; Android 12; Ubuntu Touch) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.72 Mobile Safari/537.36"
    }

    // Dialog for country selection
    Dialog {
        id: countryDialog
        title: "Select Country"
        modal: true
        anchors.centerIn: parent 

        ColumnLayout {
            spacing: 10
            anchors.margins: 10

            ComboBox {
                id: countryDropdown
                model: ['Australia', 'Belgium', 'Brazil', 'Canada', 'France', 'Germany', 'India', 'Italy', 'Japan', 'Mexico', 'Netherlands', 'Saudi Arabia', 'Singapore', 'Spain', 'Turkey', 'UAE', 'UK', 'US']
                currentIndex: 0 
                onCurrentIndexChanged: {
                    selectedCountry = model[currentIndex];  // Update selectedCountry based on index
                }
                Layout.alignment: Qt.AlignHCenter // Center in the layout
            }

            Button {
                text: "Confirm"
                Layout.alignment: Qt.AlignHCenter // Center in the layout
                onClicked: {
                    countryDialog.close()
                    loadWebView()
                    appSettings.selectedCountry = selectedCountry;  // Save the selection
                }
            }
        }
    }

    // Function to load the webview with the selected country
    function loadWebView() {
      var countryUrls = {
        "Australia": "https://www.amazon.com.au/",
        "Belgium": "https://www.amazon.com.be/",
        "Brazil": "https://www.amazon.com.br/",
        "Canada": "https://www.amazon.ca/",
        "France": "https://www.amazon.fr/",
        "Germany": "https://www.amazon.de/",
        "India": "https://www.amazon.in/",
        "Italy": "https://www.amazon.it/",
        "Japan": "https://www.amazon.jp/",
        "Mexico": "https://www.amazon.com.mx/",
        "Netherlands": "https://www.amazon.nl/",
        "Saudi Arabia": "https://www.amazon.sa/",
        "Singapore": "https://www.amazon.sg/",
        "Spain": "https://www.amazon.es/",
        "Turkey": "https://www.amazon.com.tr/",
        "UAE": "https://www.amazon.ae/",
        "UK": "https://www.amazon.co.uk/",
        "US": "https://www.amazon.com/"
      };

      // Get the URL based on the selected country
      var baseUrl = countryUrls[selectedCountry] || "https://www.amazon.com/"; // Default to US if country not found
      webview.url = baseUrl;
    }

    // Show the dialog on startup or load saved country
    Component.onCompleted: {
        selectedCountry = appSettings.selectedCountry; // Load saved country or default to India
        if (selectedCountry) {
            loadWebView(); // Load webview directly with saved country
        } else {
            countryDialog.open(); // Open dialog if no selection is found
        }
    }

    WebView {
        id: webview
        anchors.fill: parent
        //url: "https://www.amazon.com/"
        anchors.bottom: navBar.top
        profile: defaultProfile
        zoomFactor: 0.7
        settings.fullScreenSupportEnabled: true
        settings.dnsPrefetchEnabled: true
        enableSelectOverride: true
        property var currentWebview: webview
        property ContextMenuRequest contextMenuRequest: null
        settings.pluginsEnabled: true
        settings.javascriptCanAccessClipboard: true

        onFeaturePermissionRequested: grantFeaturePermission(url, WebEngineView.MediaAudioVideoCapture, true);

        onFullScreenRequested: function(request) {
            request.accept();
            navBar.visible = !navBar.visible
            if (request.toggleOn) {
                window.showFullScreen();
            } else {
                window.showNormal();
            }
        }

        onLoadingChanged: {
            if (loadRequest.status === WebEngineLoadRequest.LoadStartedStatus) {
                window.loaded = true
            } else if (loadRequest.status === WebEngineLoadRequest.LoadFailedStatus) {
                window.onError = true
            }
        }

        onNewViewRequested: function(request) {
            var url = request.requestedUrl.toString()
            if (url.startsWith('https://www.amazon')) {
                var reg = new RegExp('[?&]q=([^&#]*)', 'i');
                var param = reg.exec(url);
                if (param) {
                    Qt.openUrlExternally(decodeURIComponent(param[1]))
                } else {
                    Qt.openUrlExternally(url)
                    request.action = WebEngineNavigationRequest.IgnoreRequest;
                }
            } else {
                Qt.openUrlExternally(url)
            }
        }

        onContextMenuRequested: function(request) {
            if (!Qt.inputMethod.visible) {
                request.accepted = true;
                contextMenuRequest = request
                contextMenu.x = request.x;
                contextMenu.y = request.y;
                contextMenu.open();
            }
        }
    }

    // Navigation Bar
    NavBar {
        id: navBar
        webview: webview 
        anchors.bottom: parent.bottom
        anchors.top: webview.bottom
        width: parent.width
        height: 50

    }
}
