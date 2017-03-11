/**
 * @providesModule RNAdalPlugin
 * @flow
 */
'use strict';

import {
  NativeModules
} from 'react-native';

var NativeRNAdalPlugin = NativeModules.RNAdalPlugin;

/**
 * High-level docs for the RNAdalPlugin iOS API can be written here.
 */

var RNAdalPlugin = {
  test: function() {
    NativeRNAdalPlugin.test();
  }
};

module.exports = RNAdalPlugin;
