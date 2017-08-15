using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ReactNativeMSAdal
{

    public enum AuthenticationStatus
    {
        /// <summary>
        /// Authentication Success.
        /// </summary>
        Success = 0,

        /// <summary>
        /// Authentication failed due to error on client side.
        /// </summary>
        ClientError = -1,

        /// <summary>
        /// Authentication failed due to error returned by service.
        /// </summary>
        ServiceError = -2,
    }



    public class AuthenticationResult : BaseResults
    {

        public AuthenticationResult(string accessToken, Dictionary<string, string> props)
        {
            this.AccessToken = accessToken;
            this.AccessTokenType = "Bearer";
            this.Status = AuthenticationStatus.Success;

            SetProperty<DateTimeOffset>(props, "exp", val => { this.ExpiresOn = val; });
            SetProperty<string>(props, "tid", val => { this.TenantId = val; });

            UserInfo = new UserInfo(props);
        }

        AuthenticationResult(string errorCode, string errorDescription, string[] errorCodes)
        {
            this.Status = AuthenticationStatus.ServiceError;
        }

        [JsonProperty(PropertyName = "accessTokenType")]
        public string AccessTokenType { get; private set; }

        [JsonProperty(PropertyName = "accessToken")]
        public string AccessToken { get; private set; }

        [JsonProperty(PropertyName = "expiresOn")]
        public DateTimeOffset ExpiresOn { get; internal set; }

        [JsonProperty(PropertyName = "")]
        public string TenantId { get; internal set; }

        [JsonProperty(PropertyName = "userInfo")]
        public UserInfo UserInfo { get; internal set; }

        [JsonProperty(PropertyName = "idToken")]
        public string IdToken { get; internal set; }

        [JsonProperty(PropertyName = "status")]
        public AuthenticationStatus Status { get; private set; }

        [JsonProperty(PropertyName = "error")]
        public string Error { get; private set; }

        [JsonProperty(PropertyName = "errorDescription")]
        public string ErrorDescription { get; private set; }

        [JsonProperty(PropertyName = "statusCode")]
        public int StatusCode { get; internal set; }

        [JsonProperty(PropertyName = "isMultipleResourceRefreshToken")]
        public bool IsMultipleResourceRefreshToken { get; internal set; }
    }
}
