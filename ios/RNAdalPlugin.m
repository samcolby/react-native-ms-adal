/*******************************************************************************
 * Copyright (c) Microsoft Open Technologies, Inc.
 * All Rights Reserved
 * See License in the project root for license information.
 ******************************************************************************/

// Modifications by Sam Colby to work with React Native instead of Cordova

#import "RNAdalPlugin.h"
#import "RNAdalUtils.h"

#import "React/RCTLog.h"

#import <ADAL/ADAL.h>

@implementation RNAdalPlugin

RCT_EXPORT_MODULE();

#if !TARGET_OS_IPHONE
static id<ADTokenCacheDelegate> tokenCacheDelegate = nil;

+ (void)setTokenCacheDelegate:(id<ADTokenCacheDelegate>) delegate
{
    tokenCacheDelegate = delegate;
}
#endif

RCT_REMAP_METHOD(createAsync,
                 authority:(NSString *)authority
                 validateAuthority:(BOOL)validateAuthority
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject )

// - (void)createAsync:(CDVInvokedUrlCommand *)command
{
  //  [self.commandDelegate runInBackground:^{
  @try
  {
    //      NSString *authority = ObjectOrNil([command.arguments objectAtIndex:0]);
    //      BOOL validateAuthority = [[command.arguments objectAtIndex:1] boolValue];

    [RNAdalPlugin getOrCreateAuthContext:authority
                       validateAuthority:validateAuthority];

    resolve( @"success" );

    //[self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }
  @catch (ADAuthenticationError *error)
  {
    //      CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
    //                                                    messageAsDictionary:[RNAdalUtils ADAuthenticationErrorToDictionary:error]];
    //      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    reject( [[NSString alloc] initWithFormat:@"%d", error.code], error.errorDetails, error );

  }
  //  }];
}

RCT_REMAP_METHOD(acquireTokenAsync,
                 authority:(NSString *)authority
                 validateAuthority:(BOOL)validateAuthority
                 resourceId:(NSString *)resourceId
                 clientId:(NSString *)clientId
                 redirectUri:(NSString *)redirectUri
                 userId:(NSString *)userId
                 extraQueryParameters:(NSString *)extraQueryParameters
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject )
//- (void)acquireTokenAsync:(CDVInvokedUrlCommand *)command
{
  //[self.commandDelegate runInBackground:^{
  @try
  {
    //NSString *authority = ObjectOrNil([command.arguments objectAtIndex:0]);
    //BOOL validateAuthority = [[command.arguments objectAtIndex:1] boolValue];
    //      NSString *resourceId = ObjectOrNil([command.arguments objectAtIndex:2]);
    //      NSString *clientId = ObjectOrNil([command.arguments objectAtIndex:3]);
    //      NSURL *redirectUri = [NSURL URLWithString:[command.arguments objectAtIndex:4]];
    //      NSString *userId = ObjectOrNil([command.arguments objectAtIndex:5]);
    //      NSString *extraQueryParameters = ObjectOrNil([command.arguments objectAtIndex:6]);

    NSURL *urlRedirectUri = [NSURL URLWithString:redirectUri];

    ADAuthenticationContext *authContext = [RNAdalPlugin getOrCreateAuthContext:authority
                                                              validateAuthority:validateAuthority];
    // `x-msauth-` redirect url prefix means we should use brokered authentication
    // https://github.com/AzureAD/azure-activedirectory-library-for-objc#brokered-authentication
    authContext.credentialsType = (urlRedirectUri.scheme && [urlRedirectUri.scheme hasPrefix: @"x-msauth-"]) ? AD_CREDENTIALS_AUTO : AD_CREDENTIALS_EMBEDDED;

    // TODO iOS sdk requires user name instead of guid so we should map provided id to a known user name
    userId = [RNAdalUtils mapUserIdToUserName:authContext
                                            userId:userId];

    dispatch_async(dispatch_get_main_queue(), ^{
      [authContext
       acquireTokenWithResource:resourceId
       clientId:clientId
       redirectUri:urlRedirectUri
       promptBehavior:(userId != nil ? AD_PROMPT_ALWAYS : AD_PROMPT_AUTO)
       userId:userId
       extraQueryParameters:extraQueryParameters
       completionBlock:^(ADAuthenticationResult *result) {

         NSMutableDictionary *msg = [RNAdalUtils ADAuthenticationResultToDictionary: result];
         //           CDVCommandStatus status = (AD_SUCCEEDED != result.status) ? CDVCommandStatus_ERROR : CDVCommandStatus_OK;
         //           CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:status messageAsDictionary: msg];
         //           [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

         if ( AD_SUCCEEDED != result.status ) {
           reject( [[NSString alloc] initWithFormat:@"%d", result.error.code], result.error.errorDetails, result.error );
         } else {
           resolve(msg);
         }

       }];
    });
  }
  @catch (ADAuthenticationError *error)
  {
    //      CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
    //                                                    messageAsDictionary:[RNAdalUtils ADAuthenticationErrorToDictionary:error]];
    //      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    reject( [[NSString alloc] initWithFormat:@"%d", error.code], error.errorDetails, error );

  }
  //}];
}

RCT_REMAP_METHOD(acquireTokenSilentAsync,
                 authority:(NSString *)authority
                 validateAuthority:(BOOL)validateAuthority
                 resourceId:(NSString *)resourceId
                 clientId:(NSString *)clientId
                 userId:(NSString *)userId
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject )

//- (void)acquireTokenSilentAsync:(CDVInvokedUrlCommand *)command
{
  //  [self.commandDelegate runInBackground:^{
  @try
  {
    //      NSString *authority = ObjectOrNil([command.arguments objectAtIndex:0]);
    //      BOOL validateAuthority = [[command.arguments objectAtIndex:1] boolValue];
    //      NSString *resourceId = ObjectOrNil([command.arguments objectAtIndex:2]);
    //      NSString *clientId = ObjectOrNil([command.arguments objectAtIndex:3]);
    //      NSString *userId = ObjectOrNil([command.arguments objectAtIndex:4]);

    ADAuthenticationContext *authContext = [RNAdalPlugin getOrCreateAuthContext:authority
                                                              validateAuthority:validateAuthority];

    // TODO iOS sdk requires user name instead of guid so we should map provided id to a known user name
    userId = [RNAdalUtils mapUserIdToUserName:authContext
                                            userId:userId];

    [authContext acquireTokenSilentWithResource:resourceId
                                       clientId:clientId
                                    redirectUri:nil
                                         userId:userId
                                completionBlock:^(ADAuthenticationResult *result) {
                                  NSMutableDictionary *msg = [RNAdalUtils ADAuthenticationResultToDictionary: result];
                                  //                                    CDVCommandStatus status = (AD_SUCCEEDED != result.status) ? CDVCommandStatus_ERROR : CDVCommandStatus_OK;
                                  //                                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:status messageAsDictionary: msg];
                                  //                                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

//                                  RCTLogInfo(@"Result status is %u", result.status );
//                                  RCTLogInfo(@"AD_SUCCEEDED is %u", AD_SUCCEEDED );

                                  if ( AD_SUCCEEDED != result.status ) {
                                    reject( [[NSString alloc] initWithFormat:@"%d", result.error.code], result.error.errorDetails, result.error );
                                  } else {
                                    resolve(msg);
                                  }

                                }];
  }
  @catch (ADAuthenticationError *error)
  {
    //      CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
    //                                                    messageAsDictionary:[RNAdalUtils ADAuthenticationErrorToDictionary:error]];
    //      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    reject( [[NSString alloc] initWithFormat:@"%d", error.code], error.errorDetails, error );
    // reject( @"error", @"there was an error", error );
  }
  //  }];
}


RCT_REMAP_METHOD(tokenCacheClear,
                 authority:(NSString *)authority
                 validateAuthority:(BOOL)validateAuthority
                 tokenCacheClear_resolver:(RCTPromiseResolveBlock)resolve
                 tokenCacheClear_rejecter:(RCTPromiseRejectBlock)reject )


// - (void)tokenCacheClear:(CDVInvokedUrlCommand *)command
{
  //  [self.commandDelegate runInBackground:^{
  @try
  {
    ADAuthenticationError *error;

#if TARGET_OS_IPHONE
    ADKeychainTokenCache* cacheStore = [ADKeychainTokenCache new];
#else
    ADTokenCache* cacheStore = [ADTokenCache new];
#endif

    NSArray *cacheItems = [cacheStore allItems:&error];

    for (int i = 0; i < cacheItems.count; i++)
    {
      [cacheStore removeItem: cacheItems[i] error: &error];
    }

    if (error != nil)
    {
      @throw(error);
    }

    //      CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    //
    //      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    resolve(@"Success");
  }
  @catch (ADAuthenticationError *error)
  {
    //      CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
    //                                                    messageAsDictionary:[CRNAdalUtils ADAuthenticationErrorToDictionary:error]];
    //      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    reject( [[NSString alloc] initWithFormat:@"%d", error.code], error.errorDetails, error );
    //  reject( @"Error clearing cache", @"There was an error clearing the token cache", error );
  }
  //  }];
}


RCT_REMAP_METHOD(tokenCacheReadItems,
                 authority:(NSString *)authority
                 validateAuthority:(BOOL)validateAuthority
                 tokenCacheReadItems_resolver:(RCTPromiseResolveBlock)resolve
                 tokenCacheReadItems_rejecter:(RCTPromiseRejectBlock)reject )


//- (void)tokenCacheReadItems:(CDVInvokedUrlCommand *)command
{
  //  [self.commandDelegate runInBackground:^{
  @try
  {
    ADAuthenticationError *error;

#if TARGET_OS_IPHONE
    ADKeychainTokenCache* cacheStore = [ADKeychainTokenCache new];
#else
    ADTokenCache* cacheStore = [ADTokenCache new];
#endif

    //get all items from cache
    NSArray *cacheItems = [cacheStore allItems:&error];

    NSMutableArray *items = [NSMutableArray arrayWithCapacity:cacheItems.count];

    if (error != nil)
    {
      @throw(error);
    }

    for (id obj in cacheItems)
    {
      [items addObject:[RNAdalUtils ADTokenCacheStoreItemToDictionary:obj]];
    }

    //      CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
    //                                                         messageAsArray:items];
    //
    //      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

    resolve(items);

  }
  @catch (ADAuthenticationError *error)
  {
    //      CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
    //                                                    messageAsDictionary:[RNAdalUtils ADAuthenticationErrorToDictionary:error]];
    //      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    reject( [[NSString alloc] initWithFormat:@"%d", error.code], error.errorDetails, error );
    // reject( @"Error clearing cache", @"There was an error clearing the token cache", error );
  }
  //  }];
}


RCT_REMAP_METHOD(tokenCacheDeleteItem,
                 authority:(NSString *)authority
                 validateAuthority:(BOOL)validateAuthority
                 itemAuthority:(NSString *)itemAuthority
                 resourceId:(NSString *)resourceId
                 clientId:(NSString *)clientId
                 userId:(NSString *)userId
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject )

//- (void)tokenCacheDeleteItem:(CDVInvokedUrlCommand *)command
{
  //  [self.commandDelegate runInBackground:^{
  @try
  {
    ADAuthenticationError *error;

    //      NSString *authority = ObjectOrNil([command.arguments objectAtIndex:0]);
    //      BOOL validateAuthority = [[command.arguments objectAtIndex:1] boolValue];
    //      NSString *itemAuthority = ObjectOrNil([command.arguments objectAtIndex:2]);
    //      NSString *resourceId = ObjectOrNil([command.arguments objectAtIndex:3]);
    //      NSString *clientId = ObjectOrNil([command.arguments objectAtIndex:4]);
    //      NSString *userId = ObjectOrNil([command.arguments objectAtIndex:5]);

    ADAuthenticationContext *authContext = [RNAdalPlugin getOrCreateAuthContext:authority
                                                              validateAuthority:validateAuthority];

    // TODO iOS sdk requires user name instead of guid so we should map provided id to a known user name
    userId = [RNAdalUtils mapUserIdToUserName:authContext
                                            userId:userId];

#if TARGET_OS_IPHONE
    ADKeychainTokenCache* cacheStore = [ADKeychainTokenCache new];
#else
    ADTokenCache* cacheStore = [ADTokenCache new];
#endif

    //get all items from cache
    NSArray *cacheItems = [cacheStore allItems:&error];

    if (error != nil)
    {
      @throw(error);
    }

    for (ADTokenCacheItem*  item in cacheItems)
    {
      NSDictionary *itemAllClaims = [[item userInformation] allClaims];

      NSString * userUniqueName = (itemAllClaims && itemAllClaims[@"unique_name"]) ? itemAllClaims[@"unique_name"] : nil;

      if ([itemAuthority isEqualToString:[item authority]]
          && ((userUniqueName != nil && [userUniqueName isEqualToString:userId])
              || [userId isEqualToString:[[item userInformation] userId]])
          && [clientId isEqualToString:[item clientId]]
          // resource could be nil which is fine
          && ((!resourceId && ![item resource]) || [resourceId isEqualToString:[item resource]])) {

        //remove item
        [cacheStore removeItem:item error: &error];

        if (error != nil)
        {
          @throw(error);
        }
      }

    }

    //      CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    //      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    resolve(@"success");
  }
  @catch (ADAuthenticationError *error)
  {
    //      CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
    //                                                    messageAsDictionary:[RNAdalUtils ADAuthenticationErrorToDictionary:error]];
    //      [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    reject( [[NSString alloc] initWithFormat:@"%d", error.code], error.errorDetails, error );
    // reject( @"Error clearing cache", @"There was an error clearing the token cache", error );
  }
  //  }];
}

static NSMutableDictionary *existingContexts = nil;

+ (ADAuthenticationContext *)getOrCreateAuthContext:(NSString *)authority
                                  validateAuthority:(BOOL)validate
{
  if (!existingContexts)
  {
    existingContexts = [NSMutableDictionary dictionaryWithCapacity:1];
  }

  ADAuthenticationContext *authContext = [existingContexts objectForKey:authority];

  if (!authContext)
  {
    ADAuthenticationError *error;

#if TARGET_OS_IPHONE
      authContext = [ADAuthenticationContext authenticationContextWithAuthority:authority
                                                              validateAuthority:validate
                                                                          error:&error];
#else
      authContext = [[ADAuthenticationContext alloc] initWithAuthority:authority
                                                     validateAuthority:validate
                                                         cacheDelegate:tokenCacheDelegate
                                                                 error:&error];
#endif

    if (error != nil)
    {
      @throw(error);
    }

    [existingContexts setObject:authContext forKey:authority];
  }

  return authContext;
}

static id ObjectOrNil(id object)
{
  return [object isKindOfClass:[NSNull class]] ? nil : object;
}

@end
