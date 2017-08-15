using ReactNative.Modules.Core;
using System;
using System.Collections.Generic;
using ReactNative.Bridge;
using ReactNative.UIManager;

namespace ReactNativeMSAdal
{
    public class ReactNativeMSAdalPackage : IReactPackage
    {
        public IReadOnlyList<Type> CreateJavaScriptModulesConfig()
        {
            return Array.Empty<Type>();
        }

        public IReadOnlyList<INativeModule> CreateNativeModules(ReactContext reactContext)
        {
            return new List<INativeModule>
            {
                new ReactNativeMSAdalModule(reactContext)
            };
        }

        public IReadOnlyList<IViewManager> CreateViewManagers(ReactContext reactContext)
        {
            return new List<IViewManager>(0);
        }
    }
}
