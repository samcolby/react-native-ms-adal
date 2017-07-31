// Copyright (c) Microsoft Open Technologies, Inc.  All rights reserved.  Licensed under the Apache License, Version 2.0.  See License.txt in the project root for license information.

// Modifications by Sam Colby to work with React Native instead of Cordova

/*global module, require*/

import UserInfo from './UserInfo';

/**
 * Represents the result token acquisition operation.
 */
function AuthenticationResult(authResult) {
    this.accessToken = authResult.accessToken;
    this.accessTokenType = authResult.accessTokenType;
    this.expiresOn = authResult.expiresOn ? new Date(authResult.expiresOn) : null;
    this.idToken = authResult.idToken;
    this.isMultipleResourceRefreshToken = authResult.isMultipleResourceRefreshToken;
    this.status = authResult.status;
    this.statusCode = authResult.statusCode;
    this.tenantId = authResult.tenantId;

    var jwtToken = authResult.idToken || authResult.accessToken;
    this.userInfo = new UserInfo(authResult.userInfo);
}

/**
 * Creates authorization header for web requests.
 *
 * @returns {String} The authorization header.
 */
AuthenticationResult.prototype.createAuthorizationHeader = function() {
    return "Bearer " + this.accessToken;
};

module.exports = AuthenticationResult;
