// Copyright (c) Microsoft Open Technologies, Inc.  All rights reserved.  Licensed under the Apache License, Version 2.0.  See License.txt in the project root for license information.

// Modifications by Sam Colby to work with React Native instead of Cordova

/**
 * Represents information about authorized user.
 */
function UserInfo(userInfo) {

    userInfo = userInfo || {};

    this.displayableId = userInfo.displayableId;
    this.userId = userInfo.userId || userInfo.uniqueId;
    this.familyName = userInfo.familyName;
    this.givenName = userInfo.givenName;
    this.identityProvider = userInfo.identityProvider;
    this.passwordChangeUrl = userInfo.passwordChangeUrl;
    this.passwordExpiresOn = userInfo.passwordExpiresOn ? new Date(userInfo.passwordExpiresOn) : null;
    this.uniqueId = userInfo.uniqueId;
}

module.exports = UserInfo;
