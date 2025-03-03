using avEncDec_r1;
using avEncDec_r1.Controllers;
using avEncDec_r1.Model;
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
using Windows.ApplicationModel.Email.DataProvider;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.TrackBar;

namespace avEncDec_w1.UserControls.FunStuffUC
{
    public partial class BatchRun : UserControl
    {
        static string SASHOME = "C:\\Program Files\\SASHome\\SASFoundation\\9.4\\sas.exe\" -CONFIG \"C:\\Program Files\\SASHome\\SASFoundation\\9.4\\nls\\u8\\sasv9.cfg";
        public BatchRun()
        {
            InitializeComponent();
        }
        static List<Batch_Helper> runables = new List<Batch_Helper>();
        public static List<CoolStuff> Selectables = new List<CoolStuff>();

 

        public class CoolStuff
        {
            public string PathToFile { get; set; }
            public int Batch_Order { get; set; }

        }
        private async void btnDoBatch_Click(object sender, EventArgs e)
        {
            string directorypath = @"C:\sas_temp\";
            FolderBrowserDialog ofd = new FolderBrowserDialog();
            DialogResult result = ofd.ShowDialog();
            List<Task> tasks = new List<Task>();
            if (result == DialogResult.OK)
            {
                runables = await new Batch_Helpers().getbatch_Helpers();
                directorypath += Guid.NewGuid().ToString().Split('-')[0];
                Directory.CreateDirectory(directorypath);
                GetAllFiles(ofd.SelectedPath);
                for (int i = 0; i < Selectables.Count; i++)
                {
                    //tasks.Add(Task.Factory.StartNew(async () =>
                    //{
                        FileInfo loc = new FileInfo(Selectables[i].PathToFile);
                        try
                        {
                            var b = await GetUserFile(Selectables[i].PathToFile);
                            if (b != null)
                            {
                                var c = await GetUserForFile(b.UserID);
                                File.WriteAllText(directorypath + "\\" + loc.Name, EncDec.Decrypt(File.ReadAllText(loc.FullName), c.PKey));
                            }
                            else
                            {
                                File.WriteAllText(directorypath + "\\" + loc.Name, File.ReadAllText(loc.FullName));
                            }
                        }
                        catch
                        {
                            File.Copy(Selectables[i].PathToFile, directorypath + "\\" + loc.Name, true);
                        }
                        Selectables[i].PathToFile = directorypath + "\\" + loc.Name;
                    //}));
                }
                //Task.WaitAll(tasks.ToArray());

                for (int i = 0; i < 500; i++)
                {
                    tasks = new List<Task>();
                    foreach (var b in Selectables.Where(p => p.Batch_Order == i))
                    {
                        tasks.Add(Task.Factory.StartNew(() =>
                        {
                            string FileName = new FileInfo(b.PathToFile).Name.Split('.')[0];

                            string TempLog = directorypath + @"\" + FileName + ".log";
                            string Tempoutput = directorypath + @"\" + FileName + ".output";

                            string command = "::@echo off" + Environment.NewLine + "CALL \"" + SASHOME + "\" -SYSIN " + "\"" + directorypath + @"\" + FileName + ".sas" + "\" -PRINT '" + Tempoutput + "' -LOG '" + TempLog + "' -ICON -NOSPLASH";
                            File.WriteAllText(directorypath + @"\" + FileName + ".bat", command);

                            ProcessStartInfo info = new ProcessStartInfo(directorypath + @"\" + FileName + ".bat");
                            info.WindowStyle = ProcessWindowStyle.Minimized;
                            Process process = Process.Start(info);
                            process.WaitForExit();
                        }));
                    }
                    Task.WaitAll(tasks.ToArray());
                }


            }
        }
        static void GetAllFiles(string path)
        {
            try
            {
                // Get all files in the current directory
                List<Task> tasks = new List<Task>();
                foreach (string file in Directory.EnumerateFiles(path, "*.sas", SearchOption.AllDirectories))
                {
                    tasks.Add(Task.Factory.StartNew(() =>
                    {
                        FileInfo f = new FileInfo(file);
                        string s = f.Name.ToUpper().Split('.')[0];

                        var run = runables.FirstOrDefault(p => p.DSNAME.ToUpper() == s);
                        if (run != null)
                        {
                            Selectables.Add(new CoolStuff { Batch_Order = run.BatchOrder, PathToFile = file });
                        }
                    }));
                }
                Task.WaitAll(tasks.ToArray());

            }
            catch (Exception e)
            {
                Console.WriteLine($"An error occurred: {e.Message}");
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
