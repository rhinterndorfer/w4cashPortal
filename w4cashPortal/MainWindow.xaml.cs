using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace w4cashPortal
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();

            textBoxPortalUrl.Text = ConfigurationHelper.ReadSetting("PortalURL") ?? "http://localhost:8888/apex/f?p=102";
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            ConfigurationHelper.WriteSetting("PortalURL", textBoxPortalUrl.Text);
            Process.Start(textBoxPortalUrl.Text);
        }
    }
}
