# react-native-ms-adal

This is a currently 'ios only' port of the [Active Directory Authentication Library (ADAL) plugin for Apache Cordova apps](https://github.com/AzureAD/azure-activedirectory-library-for-cordova).

This is alpha software and not everything is tested, but does allow the basic authentication functions and keychain stuff.

Hopefully Microsoft will release an official version soon.

## Installation

1. `npm install --save react-native-ms-adal`
2. Add the ADAL ios library to your ios/podfile file `pod 'ADAL', '~> 2.3'`
3. `cd ios && pod install`
4. `react-native link react-native-ms-adal`
