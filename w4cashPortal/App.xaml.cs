using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Deployment.Application;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;

namespace w4cashPortal
{
    /// <summary>
    /// Interaction logic for App.xaml
    /// </summary>
    public partial class App : Application
    {
        private void Application_Startup(object sender, StartupEventArgs e)
        {
            ClickOnceHelper.CleanUpLocalDeploymentVersions();


            // check last version
            string lastVersion = ConfigurationHelper.ReadSetting("LastStartUpVersion");
            Assembly currentEntyAssembly = Assembly.GetEntryAssembly();
            Version v = currentEntyAssembly.GetName().Version;
            string currentVersion = v.ToString();
            
            if(!currentVersion.Equals(lastVersion))
            {
                // run update
                if(!WindowsHelper.IsAdministrator())
                { 
                    WindowsHelper.RunAsAdministrator();
                    Application.Current.Shutdown();
                    return;
                }

                // run sqlplus as sysdba
                ProcessStartInfo startInfo = new ProcessStartInfo();
                startInfo.WorkingDirectory = Path.GetDirectoryName(currentEntyAssembly.Location);
                startInfo.FileName = "sqlplus";
                startInfo.Arguments = "/ as sysdba @upgrade.sql";
                startInfo.UseShellExecute = false;
                startInfo.EnvironmentVariables.Add("NLS_LANG", "AMERICAN_AMERICA.UTF8");

                Process p = Process.Start(startInfo);
                while(!p.HasExited)
                {
                    Thread.Sleep(500);
                }

                // store last version
                ConfigurationHelper.WriteSetting("LastStartUpVersion", currentVersion);
            }


            // open portal and exit
            string portalURL = ConfigurationHelper.ReadSetting("PortalURL");
            if(!String.IsNullOrEmpty(portalURL))
            {
                // open portal and exit
                Process.Start(portalURL);
                Application.Current.Shutdown();
                return;
            }

            // else show configuration UI

        }
    }
}
