// Copyright (c) Microsoft Open Technologies, Inc.  All rights reserved.  Licensed under the Apache License, Version 2.0.  See License.txt in the project root for license information.

// Modifications by Sam Colby to work with React Native instead of Cordova

/*global module, require*/

import {
  NativeModules
} from 'react-native';
const RNAdalPlugin = NativeModules.RNAdalPlugin;


var TokenCacheItem = require('./TokenCacheItem');
var Deferred = require('./utility').Utility.Deferred;

/**
 * Token cache class used by {AuthenticationContext} to store access and refresh tokens.
 */
function TokenCache(authContext) {
    this.authContext = authContext;
}

/**
 * Clears the cache by deleting all the items.
 *
 * @returns {Promise} Promise either fulfilled when operation is completed or rejected with error.
 */
TokenCache.prototype.clear = function () {
    return RNAdalPlugin.tokenCacheClear( this.authContext.authority, this.authContext.validateAuthority );
};

/**
 * Gets all cached items.
 *
 * @returns {Promise} Promise either fulfilled with array of cached items or rejected with error.
 */
TokenCache.prototype.readItems = function () {

    var result = [];

    var d = new Deferred();

    RNAdalPlugin.tokenCacheReadItems( this.authContext.authority, this.authContext.validateAuthority )
    .then(function (tokenCacheItems) {
        tokenCacheItems.forEach(function (item) {
            result.push(new TokenCacheItem(item));
        });
        d.resolve(result);
    }, function(err) {
        d.reject(err);
    });

    return d;
};

/**
 * Deletes cached item.
 *
 * @param   {TokenCacheItem}  item Cached item to delete from cache
 *
 * @returns {Promise} Promise either fulfilled when operation is completed or rejected with error.
 */
TokenCache.prototype.deleteItem = function (item) {

    var args = [
        this.authContext.authority,
        this.authContext.validateAuthority,
        item.authority,
        item.resource,
        item.clientId,
        item.userInfo && item.userInfo.userId,
        item.isMultipleResourceRefreshToken
    ];

    return RNAdalPlugin.tokenCacheDeleteItem(
        this.authContext.authority,
        this.authContext.validateAuthority,
        item.authority,
        item.resource,
        item.clientId,
        item.userInfo && item.userInfo.userId,
        item.isMultipleResourceRefreshToken
    );
};

module.exports = TokenCache;
