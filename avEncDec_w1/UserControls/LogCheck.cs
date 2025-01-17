using avEncDec_r1;
using avEncDec_r1.Controllers;
using avEncDec_r1.Model;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Windows.Devices.WiFi;

namespace avEncDec_w1.UserControls
{
    public partial class LogCheck : UserControl
    {
        public LogCheck()
        {
            InitializeComponent();
        }

        private async void btnDoLogs_Click(object sender, EventArgs e)
        {
            DialogResult res = fbdPath.ShowDialog(this);
            if (res == DialogResult.OK)
            {
                lblPath.Text = fbdPath.SelectedPath;
                //DirectoryInfo dir = new DirectoryInfo(lblPath.Text);
                //if (dir.Exists)
                //{
                //    string directorypath = @"C:\sas_temp\" + Guid.NewGuid().ToString().Split('-')[0];
                //    Directory.CreateDirectory(directorypath);
                //    List<Task> tasks = new List<Task>();
                //    foreach (var i in Directory.GetFiles(dir.FullName, "*.log"))
                //    {
                //        FileInfo _log = new FileInfo(i);
                //        string _tmpFileName = Guid.NewGuid().ToString().Split('-')[0] + ".log";
                //        try
                //        {
                //            var b = await GetUserFile(i);
                //            var c = await GetUserForFile(b.UserID);
                //            tasks.Add(Task.Factory.StartNew(() =>
                //            {
                //                File.WriteAllText(directorypath + "/" + _tmpFileName, EncDec.Decrypt(File.ReadAllText(_log.FullName), c.PKey));
                //            }));
                //        }
                //        catch
                //        {
                //            File.WriteAllText(directorypath + "/" + _tmpFileName, File.ReadAllText(_log.FullName));
                //        }
                //    }
                //    Task.WaitAll(tasks.ToArray());
                //}
                //else
                //{
                //    MessageBox.Show("Directory does not exisit", "Warning", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                //}
            }
        }

        private async Task<UserFile> GetUserFile(string filePath)
        {
            UserFiles _n = new UserFiles();
            return await _n.getUserFile(filePath);
        }

        private async Task<UserProfile> GetUserForFile(Guid userguid)
        {
            User _u = new User();
            return await _u.getSubUser(userguid);
        }


    }
}
