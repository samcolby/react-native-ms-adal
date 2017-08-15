using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.Security.Authentication.Web.Core;
using Windows.Security.Credentials;
using System.Threading.Tasks;
using Windows.UI.Core;
using Windows.ApplicationModel.Core;

namespace ReactNativeMSAdal
{
    public class ReactNativeMSAdalModule : ReactContextNativeModuleBase, ILifecycleEventListener
    {

        public ReactNativeMSAdalModule(ReactContext reactContext)
            : base(reactContext)
        {
        }

        public override string Name
        {
            get
            {
                return "RNAdalPlugin";
            }
        }

        async private Task<WebAccountProvider> getOrCreateContext(string authority)
        {
            return await WebAuthenticationCoreManager.FindAccountProviderAsync("https://login.microsoft.com", authority);
        }

        [ReactMethod]
        async public void createAsync(string authority, bool validateAuthority, IPromise promise)
        {
            try
            {
                await getOrCreateContext(authority);
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
            WebAccountProvider authContext;
            try
            {
                authContext = await getOrCreateContext(authority);
            }
            catch (Exception ex)
            {
                promise.Reject(ex);
                return;
            }


            RunOnDispatcher( async () =>
            {
                try
                {
                    WebTokenRequest wtr = new WebTokenRequest(authContext, "", clientId, WebTokenRequestPromptType.Default);
                    wtr.Properties.Add("resource", resourceUrl);

                    WebTokenRequestResult wtrr = await WebAuthenticationCoreManager.RequestTokenAsync(wtr);
                    // WebAccount userAccount;
                    if (wtrr.ResponseStatus == WebTokenRequestStatus.Success)
                    {
                        WebTokenResponse response = wtrr.ResponseData[0];

                        var props = new Dictionary<string, string>(response.Properties);
                        
                        AuthenticationResult result = new AuthenticationResult(response.Token, props);

                        promise.Resolve(result);
                    }
                    else
                    {
                        promise.Reject($"{wtrr.ResponseError.ErrorCode}", new Exception(wtrr.ResponseError.ErrorMessage));
                    }
                }
                catch (Exception ex)
                {
                    promise.Reject(ex);
                    return;
                }
            });
            
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
            WebAccountProvider authContext;
            try
            {
                authContext = await getOrCreateContext(authority);
            }
            catch (Exception ex)
            {
                promise.Reject(ex);
                return;
            }

            try
            {
                WebTokenRequest wtr = new WebTokenRequest(authContext, "", clientId, WebTokenRequestPromptType.Default);
                wtr.Properties.Add("resource", resourceUrl);

                WebTokenRequestResult wtrr = await WebAuthenticationCoreManager.GetTokenSilentlyAsync(wtr);

                if (wtrr.ResponseStatus == WebTokenRequestStatus.Success)
                {
                    WebTokenResponse response = wtrr.ResponseData[0];

                    var props = new Dictionary<string, string>(response.Properties);

                    AuthenticationResult result = new AuthenticationResult(response.Token, props);

                    promise.Resolve(result);
                }
                else
                {
                    promise.Reject($"{wtrr.ResponseError.ErrorCode}", new Exception(wtrr.ResponseError.ErrorMessage));
                }
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



        public void OnDestroy()
        {
            throw new NotImplementedException();
        }

        public void OnResume()
        {
            throw new NotImplementedException();
        }

        public void OnSuspend()
        {
            throw new NotImplementedException();
        }

        /// <summary>
        /// Run action on UI thread.
        /// </summary>
        /// <param name="action">The action.</param>
        private static async void RunOnDispatcher(DispatchedHandler action)
        {
            await CoreApplication.MainView.CoreWindow.Dispatcher.RunAsync(CoreDispatcherPriority.Normal, action).AsTask().ConfigureAwait(false);
        }
    }
}
