using avEncDec_r1;
using avEncDec_r1.Controllers;
using avEncDec_r1.Model;
using avEncDec_w1.Toasts;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
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
        static string SASHOME = "C:\\Program Files\\SASHome\\SASFoundation\\9.4\\sas.exe\" -CONFIG \"C:\\Program Files\\SASHome\\SASFoundation\\9.4\\nls\\u8\\sasv9.cfg";
        public LogCheck()
        {
            InitializeComponent();
        }

        private async void btnDoLogs_Click(object sender, EventArgs e)
        {
            btnDoLogs.Enabled = false;  
            DialogResult res = fbdPath.ShowDialog(this);
            if (res == DialogResult.OK)
            {
                lblPath.Text = fbdPath.SelectedPath;
                DirectoryInfo dir = new DirectoryInfo(lblPath.Text);
                if (dir.Exists)
                {
                    string directorypath = @"C:\sas_temp\" + Guid.NewGuid().ToString().Split('-')[0];
                    Directory.CreateDirectory(directorypath);
                    List<Task> tasks = new List<Task>();
                    foreach (var i in Directory.GetFiles(dir.FullName, "*.log"))
                    {
                        FileInfo _log = new FileInfo(i);
                        string _tmpFileName = Guid.NewGuid().ToString().Split('-')[0] + ".log";
                     
                            var b = await GetUserFile(i);
                        if (b != null)
                        {
                            var c = await GetUserForFile(b.UserID);
                            tasks.Add(Task.Factory.StartNew(() =>
                            {
                                File.WriteAllText(directorypath + "/" + _log.Name, EncDec.Decrypt(File.ReadAllText(_log.FullName), c.PKey));
                            }));
                        }
                        else
                        {
                            tasks.Add(Task.Factory.StartNew(() =>
                            {
                                File.WriteAllText(directorypath + "/" + _log.Name, File.ReadAllText(_log.FullName));
                            }));
                        }
                    }
                    Task.WaitAll(tasks.ToArray());
                    string FileName = Guid.NewGuid().ToString().Split('-')[1];
                    string sasfile = @"%include 'T:\Standard Programs\Prod\v3.0\Medrio\08_Final Programs\01_Macros\avLogcheckFolder.sas';" +Environment.NewLine;
                    string repPath = "";
                    for(int  i = 0; i < 6;i++)
                    {
                        repPath += fbdPath.SelectedPath.Split('\\')[i] +"\\" ;
                    }
                    repPath += @"05_OutputDocs\04_Reports\";
                    sasfile += "%avLogcheckFolder(logPath="+directorypath+ " ,repPath="+ repPath + " , includeSetupPath="+fbdPath.SelectedPath +");";
                    Directory.CreateDirectory(directorypath + @"\busybox\");
                    File.WriteAllText(directorypath+@"\busybox\"+ FileName+".sas",sasfile);

                    string TempLog = directorypath+ @"\busybox\" + FileName + ".log";
                    string Tempoutput = directorypath + @"\busybox\" + FileName + ".output";

                    string command = "::@echo off" + Environment.NewLine + "CALL \"" + SASHOME + "\" -SYSIN " + "\"" + directorypath + @"\busybox\" + FileName + ".sas" + "\" -PRINT '" + Tempoutput + "' -LOG '" + TempLog + "' -ICON -NOSPLASH";

                    File.WriteAllText(directorypath + @"\busybox\" + FileName + ".bat", command);

                    ProcessStartInfo info = new ProcessStartInfo(directorypath + @"\busybox\" + FileName + ".bat");
                    info.WindowStyle = ProcessWindowStyle.Minimized;
                    Process process = Process.Start(info);
                    process.WaitForExit();

                     //Directory.Delete(directorypath, true);

                    btnDoLogs.Enabled = true;
                    ToastForm toast = new ToastForm("Success", "Log Checks done");
                    toast.Show();
                }
                else
                {
                    MessageBox.Show("Directory does not exisit", "Warning", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
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
