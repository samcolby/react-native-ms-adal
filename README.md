# react-native-ms-adal

This is a currently 'ios only' port of the [Active Directory Authentication Library (ADAL) plugin for Apache Cordova apps](https://github.com/AzureAD/azure-activedirectory-library-for-cordova). To work with React Native.

This is alpha software and not everything is tested, but does allow the basic authentication functions and keychain stuff.

Hopefully Microsoft will release an official version soon.

## Installation

1. `npm install --save react-native-ms-adal`
2. cd ios and add the ADAL ios library to your ios/Podfile file `pod 'ADAL', '~> 2.3'`
3. run `pod install` to pull the ios ADAL library down.
4. In you react-native project root folder run `react-native link react-native-ms-adal`

At the moment, the following code should get you started.


See the linked above cordova library for full instructions on how to configure
