using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace w4cashPortal
{
    public class ClickOnceHelper
    {
        public static void CleanUpLocalDeploymentVersions()
        {
            Assembly currentEntyAssembly = Assembly.GetEntryAssembly();
            string currentDirectory = Path.GetDirectoryName(currentEntyAssembly.Location);
            string manifestsDirectory = Path.GetFullPath(Path.Combine(currentDirectory, @"..\manifests"));
            string deploymentDirectory = Path.GetDirectoryName(manifestsDirectory);

            if (Directory.Exists(manifestsDirectory))
            {
                // do cleanup
                // walk thru manifests and find old versions   
                FileInfo[] manifestFiles = new DirectoryInfo(manifestsDirectory).GetFiles("*.manifest");
                foreach (FileInfo manifestFile in manifestFiles)
                {
                    // check if older version exists
                    string equalNamePart = manifestFile.Name.Substring(0, manifestFile.Name.LastIndexOf('_'));
                    var oldFiles = manifestFiles.Where(f => f.Name.StartsWith(equalNamePart)
                            && !f.Name.Equals(manifestFile.Name)
                            && f.LastWriteTime < manifestFile.LastWriteTime
                        );
                    foreach (FileInfo oldFile in oldFiles)
                    {
                        try
                        {
                            // delete manifest and 
                            // cdf-ms
                            string cdfmsFileOld = Path.Combine(manifestsDirectory, Path.GetFileNameWithoutExtension(oldFile.Name) + ".cdf-ms");
                            File.Delete(cdfmsFileOld);

                            oldFile.Delete();
                        }
                        catch (Exception)
                        { // do nothing
                        }
                    }
                }


                // check old app directories
                DirectoryInfo[] appDeploymentDirectories = new DirectoryInfo(deploymentDirectory).GetDirectories();
                foreach (DirectoryInfo appDeploymentDirectory in appDeploymentDirectories.Where(d => !d.Name.Equals("manifests")))
                {
                    string equalNamePart = appDeploymentDirectory.Name.Substring(0, appDeploymentDirectory.Name.LastIndexOf('_'));


                    var oldAddDirs = appDeploymentDirectories.Where(d => d.Name.StartsWith(equalNamePart)
                            && !d.Name.Equals(appDeploymentDirectory.Name)
                            && d.LastWriteTime < appDeploymentDirectory.LastWriteTime
                        );
                    foreach (DirectoryInfo oldAppDir in oldAddDirs)
                    {
                        try { 
                            oldAppDir.Delete(true);
                        } catch(Exception)
                        {
                            // do nothing
                        }
                    }
                }
            }
        }
    }
}
