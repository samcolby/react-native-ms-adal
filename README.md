# react-native-ms-adal

This is a currently 'ios only' port of the [Active Directory Authentication Library (ADAL) plugin for Apache Cordova apps](https://github.com/AzureAD/azure-activedirectory-library-for-cordova). To work with React Native.

This is alpha software and not everything is tested, but does allow the basic authentication functions and keychain stuff.

Hopefully Microsoft will release an official version soon.

## Installation

1. `npm install --save react-native-ms-adal`
2. cd ios and add the ADAL ios library to your ios/Podfile file `pod 'ADAL', '~> 2.3'`
3. run `pod install` to pull the ios ADAL library down.
4. In you react-native project root folder run `react-native link react-native-ms-adal`

## Usage

At the moment, the following code taken from the cordova api should get you started.

```
import AuthenticationContext from "react-native-ms-adal";


const authority = "https://login.windows.net/common";
const resourceUri = "https://graph.windows.net";

const clientId = <your-redirect-url>";
const redirectUri = <your-redirect-uri>;



// Shows the user authentication dialog box if required
function authenticate(authCompletedCallback) {

    let context = new AuthenticationContext(authority);
    context.tokenCache.readItems().then(function (items) {
        if (items.length > 0) {
            authority = items[0].authority;
            context = new AuthenticationContext(authority);
        }
        // Attempt to authorize the user silently
        context.acquireTokenSilentAsync(resourceUri, clientId)
        .then(authCompletedCallback, function () {
            // We require user credentials, so this triggers the authentication dialog box
            context.acquireTokenAsync(resourceUri, clientId, redirectUri)
            .then(authCompletedCallback, function (err) {
                error("Failed to authenticate: " + err);
            });
        });
    });
}
```

Which can then be called as follows.

```
authenticate(function(authResponse) {
        console.log("Token acquired: " + authResponse.accessToken);
        console.log("Token will expire on: " + authResponse.expiresOn);
}
```


See the linked above cordova library for full instructions on how to configure the keychain etc in xcode.
