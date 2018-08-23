using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ReactNativeMSAdal
{
    public class BaseResults
    {
        protected void SetProperty<T>(Dictionary<string, string> props, string propName, Action<T> setOutput)
        {
            if (!props.ContainsKey(propName)) {
                return;
            }

            if (typeof(T) == typeof(string))
            {
                setOutput((T)Convert.ChangeType(props[propName], typeof(T)));
            }
            else if (typeof(T) == typeof(DateTimeOffset))
            {
                long ts;
                if (long.TryParse(props[propName], out ts))
                {
                    DateTimeOffset dt = DateTimeOffset.FromUnixTimeSeconds(ts);
                    setOutput((T)Convert.ChangeType(dt, typeof(T)));
                }
            }
        }
    }
}
