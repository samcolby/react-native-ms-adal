/*******************************************************************************
 * Copyright (c) Microsoft Open Technologies, Inc.
 * All Rights Reserved
 * See License in the project root for license information.
 ******************************************************************************/

// Modifications by Bjarte Bore to work with React Native instead of Cordova

package com.microsoft.aad.adal.rn;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.WritableMap;
import com.microsoft.aad.adal.AuthenticationCallback;
import com.microsoft.aad.adal.AuthenticationResult;


/**
 * Class that provides implementation for passing AuthenticationResult from acquireToken* methods
 * to Cordova JS code
 */
class RNDefaultAuthenticationCallback implements AuthenticationCallback<AuthenticationResult> {

    /**
     * Private field that stores cordova callback context which is used to send results back to JS
     */
    private final Promise callbackPromise;

    /**
     * Default constructor
     * @param callbackPromise Callback Promise which is used to send results back to JS
     */
    RNDefaultAuthenticationCallback(Promise callbackPromise){
        this.callbackPromise = callbackPromise;
    }

    /**
     * Success callback that serializes AuthenticationResult instance and passes it to Cordova
     * @param authResult AuthenticationResult instance
     */
    @Override
    public void onSuccess(AuthenticationResult authResult) {

        WritableMap result;
        try {
            result = RNSerialization.authenticationResultToWritableMap(authResult);
            this.callbackPromise.resolve(result);
            //callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, result));
        } catch (Exception e) {
            this.callbackPromise.reject(new Exception("Failed to serialize Authentication result"));
             //callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.JSON_EXCEPTION,
             //       "Failed to serialize Authentication result"));
        }
    }

    /**
     * Error callback that passes error to Cordova
     * @param authException AuthenticationException
     */
    @Override
    public void onError(Exception authException) {
        this.callbackPromise.reject(authException);
    }
}
