using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using avEncDec_r1.Controllers;
using avEncDec_r1.Model;
using avEncDec_w1.UserControls;
using Windows.Networking.Proximity;
using System.Threading;
using CsvHelper;
using System.Globalization;
using System.IO;
using System.Collections;
using avEncDec_w1.Toasts;
using System.Diagnostics;
using System.Runtime.InteropServices.ComTypes;



namespace avEncDec_w1
{


    public partial class avEncDec : Form
    {
        NavigationControl navigationControl;
        public avEncDec()
        {
            InitializeComponent();
            Task.Run(() => LoadData());
            Thread.Sleep(2500);
            ChangeNavClick((Button)btnDashboard);

            
            InitializeNavigationControl();
            Task.Run(() => MonitorForClosingCommand());
            

        }

        private async Task LoadUserInterface()
        {

            switch (GlobalVars._User.IsAdmin)
            {
                case false:
                    btnManage.Invoke(new MethodInvoker(delegate { btnManage.Visible = true; }));
                    //btnUserRoles.Invoke(new MethodInvoker(delegate { btnUserRoles.Visible = false; }));
                   
                    break;
                case true:
                    btnManage.Invoke(new MethodInvoker(delegate { btnManage.Visible = true; }));
                    //btnUserRoles.Invoke(new MethodInvoker(delegate { btnUserRoles.Visible = true; }));
                    break;
                     }
        }

        private async void MonitorForClosingCommand()
        {
            while (true)
            {
                Task.Delay(1000).Wait();
                // Keep the loop alive but not consuming much CPU
                if (new Log().getLogs().Result.Any(p => p.LogCategory == "Stop" && p.DateTimeLog.AddHours(1.0) > DateTimeOffset.Now))
                {
                    Environment.Exit(0);
                }
            }
        }

        public async Task LoadData()
        {
            User user = new User();
            GlobalVars._User = await user.checkUser();
            label1.Invoke(new MethodInvoker(delegate { label1.Text = GlobalVars._User.UserName; })); 
            
           
 
        }
        private void InitializeNavigationControl()
        {
            List<UserControl> userControls = new List<UserControl>()
            {
                new DashBoard(),
                new Manage(),
                new FunStuff(),
            };
            navigationControl = new NavigationControl(userControls, panel3);
            navigationControl.Display(0);
        }
        private void btnDashboard_Click(object sender, EventArgs e)
        {
            ChangeNavClick((Button)sender);
            navigationControl.Display(0);
        }
        private void ChangeNavClick(Button sender)
        {
            foreach (var button in panel1.Controls.OfType<Button>())
            {
                button.BackColor = Color.FromArgb(24, 30, 54);
            }
            //label2.Text = sender.Text;
            pnlNav.Height = sender.Height;
            pnlNav.Top = sender.Top;
            pnlNav.Left = sender.Left;
            sender.BackColor = Color.FromArgb(46, 51, 73);
        }
        private void btnManage_Click(object sender, EventArgs e)
        {
            ChangeNavClick((Button)sender);
            navigationControl.Display(1);
        }

        private void btnLogs_Click(object sender, EventArgs e)
        {
            ChangeNavClick((Button)sender);
            navigationControl.Display(2);
        }

        private void btnAnalytics_Click(object sender, EventArgs e)
        {
            ChangeNavClick((Button)sender);
        }

        private void btnSettings_Click(object sender, EventArgs e)
        {
            ChangeNavClick((Button)sender);
        }
        private void btnBatchRun_Click(object sender, EventArgs e)
        {
            ChangeNavClick((Button)sender);
        }

        private void btnTransfer_Click(object sender, EventArgs e)
        {
            ChangeNavClick((Button)sender);
        }

        private void btnLogsCheck_Click(object sender, EventArgs e)
        {
            ChangeNavClick((Button)sender);
            navigationControl.Display(2);
        }

        public class csvExprt
        {
            public DateTime DateTimeOffset { get; set; }
            public string UserName { get; set; }
            public string LogCategory { get; set; }
            public string Description { get; set; }
        }
        private async void btnExports_Click(object sender, EventArgs e)
        {
            List<csvExprt> list = new List<csvExprt>();
            foreach (var i in await new Log().getLogs())
            {
                var resUser = await new User().getSubUser(i.UserID);
                list.Add(new csvExprt() { 
                    DateTimeOffset = i.DateTimeLog.DateTime,
                    Description = i.Exception + Environment.NewLine + i.LogPath,
                    LogCategory = i.LogCategory,
                    UserName = resUser.UserName
                });
            }
            string filename = @"C:\sas_temp\" + Guid.NewGuid().ToString().Split('-')[0] + ".csv";
            using (var writer = new StreamWriter(filename))
            {
                using (var csv = new CsvWriter(writer, CultureInfo.InvariantCulture))
                {
                    csv.WriteHeader<csvExprt>();
                    csv.NextRecord();

                    foreach (var record in list)
                    {
                        csv.WriteRecord(record);
                        csv.NextRecord();
                    }
                }
            }
            ToastForm toast = new ToastForm("Success", "Exported the logs");
            toast.Show();

            Process.Start("notepad.exe", filename);

        }
    }
}
