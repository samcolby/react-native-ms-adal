/*******************************************************************************
 * Copyright (c) Microsoft Open Technologies, Inc.
 * All Rights Reserved
 * See License in the project root for license information.
 ******************************************************************************/

// Modifications by Bjarte Bore to work with React Native instead of Cordova

package com.microsoft.aad.adal.rn;

import android.app.Activity;
import android.content.Intent;
import android.os.Build;
import android.text.TextUtils;
import android.util.Log;


import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.BaseActivityEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableArray;
import com.microsoft.aad.adal.AuthenticationContext;
import com.microsoft.aad.adal.AuthenticationSettings;
import com.microsoft.aad.adal.CacheKey;
import com.microsoft.aad.adal.ITokenCacheStore;
import com.microsoft.aad.adal.ITokenStoreQuery;
import com.microsoft.aad.adal.PromptBehavior;
import com.microsoft.aad.adal.TokenCacheItem;
import com.microsoft.aad.adal.UserInfo;

import java.io.UnsupportedEncodingException;
import java.security.NoSuchAlgorithmException;
import java.security.spec.InvalidKeySpecException;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.SecretKeySpec;

public class RNAdalPlugin extends ReactContextBaseJavaModule {


  private static final PromptBehavior SHOW_PROMPT_AUTO = PromptBehavior.Auto;

  private static final int GET_ACCOUNTS_PERMISSION_REQ_CODE = 0;
  private static final String PERMISSION_DENIED_ERROR =  "Permissions denied";
  private static final String SECRET_KEY = "com.microsoft.aad.adal";

  //private Activity mActivity = null;
  private final Hashtable<String, AuthenticationContext> contexts = new Hashtable<String, AuthenticationContext>();
  private AuthenticationContext currentContext;
  //private CallbackContext callbackContext;

  private final ActivityEventListener mActivityEventListener = new BaseActivityEventListener() {

    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
    super.onActivityResult(activity, requestCode, resultCode, data);

    if (currentContext != null) {
      currentContext.onActivityResult(requestCode, resultCode, data);
    }
    }

  };

  public RNAdalPlugin(ReactApplicationContext reactContext) {
    super(reactContext);

    //mActivity = reactContext.getCurrentActivity();
    reactContext.addActivityEventListener(mActivityEventListener);

    // Android API < 18 does not support AndroidKeyStore so ADAL requires
    // some extra work to crete and pass secret key to ADAL.
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN_MR2) {
      try {
        SecretKey secretKey = this.createSecretKey(SECRET_KEY);
        AuthenticationSettings.INSTANCE.setSecretKey(secretKey.getEncoded());
      } catch (Exception e) {
        Log.w("ReactNativeMSAdalPlugin", "Unable to create secret key: " + e.getMessage());
      }
    }
  }

  @Override
  public String getName() {
    return "RNAdalPlugin";
  }

  @Override
  public Map<String, Object> getConstants() {
    final Map<String, Object> constants = new HashMap<>();
    return constants;
  }



  @ReactMethod
  public void createAsync(String authority, boolean validateAuthority, Promise promise) {

    try {
      getOrCreateContext(authority, validateAuthority);
    } catch (Exception e) {
      promise.reject(e);
      //callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, e.getMessage()));
      return;
    }
    promise.resolve(true);
  }

  @ReactMethod
  public void acquireTokenAsync(
          String authority,
          boolean validateAuthority,
          String resourceUrl,
          String clientId,
          String redirectUrl,
          String userId,
          String extraQueryParams,
          Promise promise) {

    final AuthenticationContext authContext;
    try{
      authContext = getOrCreateContext(authority, validateAuthority);
    } catch (Exception e) {
      promise.reject(e);
      return;
    }

    if (userId != null) {
      ITokenCacheStore cache = authContext.getCache();
      if (cache instanceof ITokenStoreQuery) {

        List<TokenCacheItem> tokensForUserId = ((ITokenStoreQuery)cache).getTokensForUser(userId);
        if (tokensForUserId.size() > 0) {
          // Try to acquire alias for specified userId
          userId = tokensForUserId.get(0).getUserInfo().getDisplayableId();
        }
      }
    }
    authContext.acquireToken(getCurrentActivity(), resourceUrl, clientId, redirectUrl,
            userId, SHOW_PROMPT_AUTO, extraQueryParams, new RNDefaultAuthenticationCallback(promise));
  }

  @ReactMethod
  public void acquireTokenSilentAsync(
          String authority,
          boolean validateAuthority,
          String resourceUrl,
          String clientId,
          String userId,
          Promise promise) {

    final AuthenticationContext authContext;
    try{
      authContext = getOrCreateContext(authority, validateAuthority);

      //  We should retrieve userId from broker cache since local is always empty
      boolean useBroker = AuthenticationSettings.INSTANCE.getUseBroker();
      if (useBroker) {
        if (TextUtils.isEmpty(userId)) {
          // Get first user from account list
          userId = authContext.getBrokerUser();
        }

        for (UserInfo info: authContext.getBrokerUsers()) {
          if (info.getDisplayableId().equals(userId)) {
            userId = info.getUserId();
            break;
          }
        }
      }

    } catch (Exception e) {
      promise.reject(e);
      //callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, e.getMessage()));
      return;
    }

    authContext.acquireTokenSilentAsync(resourceUrl, clientId, userId, new RNDefaultAuthenticationCallback(promise));
    return;
  }

  @ReactMethod
  private void tokenCacheReadItems(String authority, boolean validateAuthority, Promise promise) {

    final AuthenticationContext authContext;
    try{
      authContext = getOrCreateContext(authority, validateAuthority);
    } catch (Exception e) {
      promise.reject(e);
      //callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, e.getMessage()));
      return;
    }

    WritableArray result = Arguments.createArray();
    ITokenCacheStore cache = authContext.getCache();

    if (cache instanceof ITokenStoreQuery) {
      Iterator<TokenCacheItem> cacheItems = ((ITokenStoreQuery)cache).getAll();

      while (cacheItems.hasNext()) {
        TokenCacheItem item = cacheItems.next();
        try {
          result.pushMap(RNSerialization.tokenItemToWritableMap(item));
        }
        catch(Exception e){
        }

      }
    }

    promise.resolve(result);

    return;
  }

  @ReactMethod
  public void tokenCacheDeleteItem(
          String authority,
          boolean validateAuthority,
          String itemAuthority,
          String resourceId,
          String clientId,
          String userId,
          boolean isMultipleResourceRefreshToken,
          Promise promise) {

    final AuthenticationContext authContext;
    try{
      authContext = getOrCreateContext(authority, validateAuthority);
    } catch (Exception e) {
      promise.reject(e);
      return;
    }

    String key = CacheKey.createCacheKey(itemAuthority, resourceId, clientId, isMultipleResourceRefreshToken, userId, null);
    authContext.getCache().removeItem(key);

    promise.resolve(true);
    //callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
    return;
  }

  @ReactMethod
  public void tokenCacheClear(String authority, boolean validateAuthority, Promise promise) {
    final AuthenticationContext authContext;
    try{
      authContext = getOrCreateContext(authority, validateAuthority);
    } catch (Exception e) {
      promise.reject(e);
      //callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, e.getMessage()));
      return;
    }

    authContext.getCache().removeAll();
    promise.resolve(true);
    //callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK));
    return;
  }

  private AuthenticationContext getOrCreateContext (String authority, boolean validateAuthority) throws NoSuchPaddingException, NoSuchAlgorithmException {

    AuthenticationContext result;
    if (!contexts.containsKey(authority)) {
      result = new AuthenticationContext(getCurrentActivity(), authority, validateAuthority);
      this.contexts.put(authority, result);
    } else {
      result = contexts.get(authority);
    }
    // Last asked for context
    currentContext = result;
    return result;
  }

  private SecretKey createSecretKey(String key) throws NoSuchAlgorithmException, UnsupportedEncodingException, InvalidKeySpecException {
    SecretKeyFactory keyFactory = SecretKeyFactory.getInstance("PBEWithSHA256And256BitAES-CBC-BC");
    SecretKey tempkey = keyFactory.generateSecret(new PBEKeySpec(key.toCharArray(), "abcdedfdfd".getBytes("UTF-8"), 100, 256));
    SecretKey secretKey = new SecretKeySpec(tempkey.getEncoded(), "AES");
    return secretKey;
  }
}
