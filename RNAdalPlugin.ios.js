/**
 * @providesModule RNAdalPlugin
 * @flow
 */
'use strict';

var NativeRNAdalPlugin = require('NativeModules').RNAdalPlugin;

/**
 * High-level docs for the RNAdalPlugin iOS API can be written here.
 */

var RNAdalPlugin = {
  test: function() {
    NativeRNAdalPlugin.test();
  }
};

module.exports = RNAdalPlugin;
