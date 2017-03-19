# react-native-ms-adal

This is a currently an 'ios only' port of the [Active Directory Authentication Library (ADAL) plugin for Apache Cordova apps](https://github.com/AzureAD/azure-activedirectory-library-for-cordova) to work with React Native.

This is alpha software and not everything is tested, but does allow the basic authentication functions and keychain stuff.

Hopefully Microsoft will release an official version soon.

## Prerequisites

1. A working react native project.  Tested on react-native 0.41 and above
2. A working CocoaPods installation [CocoaPods - Getting Started](https://guides.cocoapods.org/using/getting-started.html)

## Installation

1. Install from npm `npm install --save react-native-ms-adal`
2. Add the ADAL ios library to your ios/Podfile file  `pod 'ADAL', '~> 2.3'`.  Create Podfile with `pod init` if required.
3. Run `pod install` to pull the ios ADAL library down.
4. In you react-native project root folder run `react-native link react-native-ms-adal`

## Usage Example

See [Active Directory Authentication Library (ADAL) plugin for Apache Cordova apps](https://github.com/AzureAD/azure-activedirectory-library-for-cordova) for details on how to use the AuthenticationContext.  This library renames this to MSAdalAuthenticationContext, which can be imported as follows

```javascript
import {MSAdalAuthenticationContext} from "react-native-ms-adal";
```

There are also couple of promised based utility functions to provide login and logout functionality. The login method will first try using the acquireTokenSilentAsync function to login using the details stored in the keychain.

```javascript
import {MSAdalLogin, MSAdalLogout} from "react-native-ms-adal";

const authority = "https://login.windows.net/common";
const resourceUri = "https://graph.windows.net";

const clientId = <your-client-id>;
const redirectUri = <your-redirect-uri>;

const msAdalPromise = MSAdalLogin(
  authority,
  clientId,
  redirectUri,
  resourceUri
);

msAdalPromise.then(authDetails => {
  // Get the data from the server, using the Authorisation Header
  fetch(<your-url>, {
    headers: {
      "Cache-Control": "no-cache",
      Authorization: "Bearer " + authDetails.accessToken
    }
  }).then(response => {
    if (response.status === 200) {
      return response.json();
    } else {
      throw new Error("Server returned status: " + response.status + ": " + response.statusText );
    }
  }).then(json => {
    // etc
  });
});

msAdalPromise.catch(err => {
  if (err.code === "403") {
    // User has cancelled
    // We need to make sure the login button is displayed
  }
  console.log("Failed to authenticate: " + err);
});

```


See the linked above [cordova library](https://github.com/AzureAD/azure-activedirectory-library-for-cordova) for full instructions on how to configure the keychain etc in xcode.

