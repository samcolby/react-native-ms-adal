using System;
using System.Collections.Generic;
using Newtonsoft.Json;

namespace ReactNativeMSAdal
{
    public class UserInfo : BaseResults
    {
        public UserInfo(Dictionary<string, string> props) {
            SetProperty<String>(props, "unique_name", val => { this.UniqueId = val; });
            SetProperty<DateTimeOffset>(props, "exp", val => { this.PasswordExpiresOn = val; });
            SetProperty<String>(props, "given_name", val => { this.GivenName = val; });
            SetProperty<String>(props, "family_name", val => { this.FamilyName = val; });
            SetProperty<String>(props, "idp", val => { this.IdentityProvider = val; });

            SetProperty<String>(props, "oid", val => { this._oid = val; });
            SetProperty<String>(props, "upn", val => { this._upn = val; });
            SetProperty<String>(props, "sup", val => { this._sup = val; });
        }

        [JsonProperty(PropertyName = "uniqueId")]
        public string UniqueId { get; internal set; }

        [JsonProperty(PropertyName = "userId")]
        public string UserId
        {
            get
            {
                return _oid ?? _sup;
            }
        }

        [JsonProperty(PropertyName = "displayableId")]
        public string DisplayableId {
            get
            {
                return _upn;
            }
        }

        [JsonProperty(PropertyName = "givenName")]
        public string GivenName { get; internal set; }

        [JsonProperty(PropertyName = "familyName")]
        public string FamilyName { get; internal set; }

        [JsonProperty(PropertyName = "passwordExpiresOn")]
        public DateTimeOffset? PasswordExpiresOn { get; internal set; }

        [JsonProperty(PropertyName = "passwordChangeUrl")]
        public Uri PasswordChangeUrl { get; internal set; }

        [JsonProperty(PropertyName = "identityProvider")]
        public string IdentityProvider { get; internal set; }

        private string _oid { get; set; }

        private string _upn { get; set; }

        private string _sup { get; set; }

    }
}
