// Copyright (c) Microsoft Open Technologies, Inc.  All rights reserved.  Licensed under the Apache License, Version 2.0.  See License.txt in the project root for license information.

// Modifications by Sam Colby to work with React Native instead of Cordova


/*global module, require*/

import {
  NativeModules
} from 'react-native';
const RNAdalPlugin = NativeModules.RNAdalPlugin;


var Deferred = require('./utility').Utility.Deferred;

module.exports = {

    /**
     * Sets flag to use or skip authentication broker.
     * By default, the flag value is false and ADAL will not talk to broker.
     *
     * @param   {Boolean}   useBroker         Flag to use or skip authentication broker
     *
     * @returns {Promise}  Promise either fulfilled or rejected with error
     */
    setUseBroker: function(useBroker) {

        if (cordova.platformId === 'android') {
        //    return RNAdalPlugin.setUseBroker( !!useBroker );
        }

        // Broker is handled by system on Windows/iOS
        var deferred = new Deferred();
        deferred.resolve();
        return deferred;
    }
}
