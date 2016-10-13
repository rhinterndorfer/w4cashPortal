using Microsoft.Win32;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace w4cashPortal
{
    public class ConfigurationHelper
    {
        const string userRoot = "HKEY_CURRENT_USER";
        const string subkey = "SOFTWARE\\W4CASH";
        const string keyName = userRoot + "\\" + subkey;


        public static string ReadSetting(string name)
        {
            return (String)Registry.GetValue(keyName, name, null);
        }

        public static void WriteSetting(string name, string value)
        {
            Registry.SetValue(keyName, name, value, RegistryValueKind.String);
        }
    }
}
