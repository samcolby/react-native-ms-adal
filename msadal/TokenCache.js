// Copyright (c) Microsoft Open Technologies, Inc.  All rights reserved.  Licensed under the Apache License, Version 2.0.  See License.txt in the project root for license information.

// Modifications by Sam Colby to work with React Native instead of Cordova

/*global module, require*/

import {
  NativeModules
} from 'react-native';
import TokenCacheItem from './TokenCacheItem';
const RNAdalPlugin = NativeModules.RNAdalPlugin;

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
    return new Promise((resolve, reject) => {
        RNAdalPlugin.tokenCacheReadItems( this.authContext.authority, this.authContext.validateAuthority )
            .then(function (tokenCacheItems) {
                var result = [];
                tokenCacheItems.forEach(function (item) {
                    result.push(new TokenCacheItem(item));
                });
                resolve(result);
            }, reject);
      });
};

/**
 * Deletes cached item.
 *
 * @param   {TokenCacheItem}  item Cached item to delete from cache
 *
 * @returns {Promise} Promise either fulfilled when operation is completed or rejected with error.
 */
TokenCache.prototype.deleteItem = function (item) {
    return RNAdalPlugin.tokenCacheDeleteItem(
        this.authContext.authority,
        this.authContext.validateAuthority,
        item.authority,
        item.resource,
        item.clientId,
        item.userInfo && item.userInfo.userId
    );
};

module.exports = TokenCache;
