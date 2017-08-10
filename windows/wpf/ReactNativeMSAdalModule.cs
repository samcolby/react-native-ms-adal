using ReactNative.Bridge;
using System;
using System.Linq;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using System.Windows;

namespace ReactNativeMSAdal
{
    public class ReactNativeMSAdalModule : ReactContextNativeModuleBase, ILifecycleEventListener
    {

        public ReactNativeMSAdalModule(ReactContext reactContext)
            : base(reactContext)
        {
            _platformParameters = new PlatformParameters(PromptBehavior.Auto);
        }

        private IPlatformParameters _platformParameters;

        private Dictionary<string, AuthenticationContext> contexts = new Dictionary<string, AuthenticationContext>();

        private AuthenticationContext currentContext = null;

        public override string Name
        {
            get
            {
                return "RNAdalPlugin";
            }
        }

        [ReactMethod]
        public void createAsync(string authority, bool validateAuthority, IPromise promise)
        {
            try
            {
                getOrCreateContext(authority, validateAuthority);
            }
            catch (Exception ex)
            {
                promise.Reject(ex);
                return;
            }
            promise.Resolve(true);
        }

        [ReactMethod]
        async public void acquireTokenAsync(
          string authority,
          bool validateAuthority,
          string resourceUrl,
          string clientId,
          string redirectUrl,
          string userId,
          string extraQueryParams,
          IPromise promise)
        {
            AuthenticationContext authContext;
            try
            {
                authContext = getOrCreateContext(authority, validateAuthority);
            }
            catch (Exception ex)
            {
                promise.Reject(ex);
                return;
            }

            if (userId != null)
            {
                TokenCache cache = authContext.TokenCache;

                IEnumerable<TokenCacheItem> tokensForUserId = cache
                    .ReadItems()
                    .Where(item => item.DisplayableId.Equals(userId, StringComparison.CurrentCulture));

                if (tokensForUserId.Any())
                {
                    userId = tokensForUserId.First().DisplayableId;
                }
            }

            try
            {
                UserIdentifier user = UserIdentifier.AnyUser;
                if (userId != null)
                {
                    user = new UserIdentifier(userId, UserIdentifierType.OptionalDisplayableId);
                }

                AuthenticationResult result = await authContext.AcquireTokenAsync(
                    resourceUrl,
                    clientId,
                    new Uri(redirectUrl),
                    _platformParameters,
                    user,
                    extraQueryParams);

                promise.Resolve(result);
            }
            catch (Exception ex)
            {
                promise.Reject(ex);
                return;
            }
            
;
        }

        [ReactMethod]
        async public void acquireTokenSilentAsync(
          String authority,
          bool validateAuthority,
          String resourceUrl,
          String clientId,
          String userId,
          IPromise promise)
        {
            AuthenticationContext authContext;
            try
            {
                authContext = getOrCreateContext(authority, validateAuthority);
            }
            catch (Exception ex)
            {
                promise.Reject(ex);
                return;
            }
            try
            {
                UserIdentifier user = UserIdentifier.AnyUser;
                if (userId != null)
                {
                    user = new UserIdentifier(userId, UserIdentifierType.OptionalDisplayableId);
                }
                AuthenticationResult result = await authContext.AcquireTokenSilentAsync(
                    resourceUrl,
                    clientId,
                    user,
                    _platformParameters);

                promise.Resolve(result);
            }
            catch (Exception ex)
            {
                promise.Reject(ex);
                return;
            }
        }

        [ReactMethod]
        private void tokenCacheReadItems(String authority, bool validateAuthority, IPromise promise)
        {
            promise.Reject(new NotImplementedException());
        }

        [ReactMethod]
        public void tokenCacheDeleteItem(
          string authority,
          bool validateAuthority,
          string itemAuthority,
          string resourceId,
          string clientId,
          string userId,
          bool isMultipleResourceRefreshToken,
          IPromise promise)
        {
            promise.Reject(new NotImplementedException());
        }

        public void tokenCacheClear(string authority, bool validateAuthority, IPromise promise)
        {
            promise.Reject(new NotImplementedException());
        }

        private AuthenticationContext getOrCreateContext(String authority, bool validateAuthority)
        {

            AuthenticationContext result;
            if (!contexts.ContainsKey(authority))
            {
                result = new AuthenticationContext(authority, validateAuthority);
                this.contexts.Add(authority, result);
            }
            else
            {
                result = contexts[authority];
            }

            // Last asked for context
            currentContext = result;
            return result;
        }

        public void OnDestroy()
        {
            currentContext = null;
            contexts.Clear();
        }

        public void OnResume()
        {
        }

        public void OnSuspend()
        {
        }
    }
}
