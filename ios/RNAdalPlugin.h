/*******************************************************************************
 * Copyright (c) Microsoft Open Technologies, Inc.
 * All Rights Reserved
 * See License in the project root for license information.
 ******************************************************************************/

// Modifications by Sam Colby to work with React Native instead of Cordova

#import <Foundation/Foundation.h>

#import "React/RCTBridgeModule.h"

#if !TARGET_OS_IPHONE
#import <ADAL/ADTokenCache.h>
#endif

// Implements react-native plugin for Microsoft Azure ADAL
@interface RNAdalPlugin : NSObject <RCTBridgeModule>

#if !TARGET_OS_IPHONE
+ (void)setTokenCacheDelegate:(id<ADTokenCacheDelegate>) delegate;
#endif

// AuthenticationContext methods
//- (void)createAsync:(CDVInvokedUrlCommand *)command;
//- (void)acquireTokenAsync:(CDVInvokedUrlCommand *)command;
//- (void)acquireTokenSilentAsync:(CDVInvokedUrlCommand *)command;
//
//// TokenCache methods
//- (void)tokenCacheClear:(CDVInvokedUrlCommand *)command;
//- (void)tokenCacheReadItems:(CDVInvokedUrlCommand *)command;
//- (void)tokenCacheDeleteItem:(CDVInvokedUrlCommand *)command;

//+ (ADAuthenticationContext *)getOrCreateAuthContext:(NSString *)authority
//                                  validateAuthority:(BOOL)validate;
@end
