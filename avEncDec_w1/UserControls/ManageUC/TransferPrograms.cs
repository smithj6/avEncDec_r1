using avEncDec_r1;
using avEncDec_r1.Controllers;
using avEncDec_r1.Model;
using avEncDec_w1.Toasts;
using avEncDec_w1.UserControls.UserRolesUC;
using System;
using System.Collections.Generic;
using System.Data.Entity.Infrastructure;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using System.Threading.Tasks;
using System.Windows.Forms;
using Windows.UI.WindowManagement;

namespace avEncDec_w1.UserControls.ManageUC
{
    public partial class TransferPrograms : UserControl
    {
        public TransferPrograms()
        {
            InitializeComponent();
        }
        List<string> files;

        private async void btnSelectFiles_Click(object sender, EventArgs e)
        {

            OpenFileDialog ofd = new OpenFileDialog();
            ofd.Multiselect = true;
            DialogResult result = ofd.ShowDialog();

            if (result == DialogResult.OK)
            {
                if (!GlobalVars._User.IsAdmin)
                {
                    var list = await new UserRoles().getAllUserRoles(GlobalVars._User.UserID);

                    foreach (var i in list.Where(p => p.RoleOnStudy == "Lead"))
                    {
                        if (ofd.FileNames.Contains(i.StudyPath))
                        {
                            break;
                        }
                        else
                        {
                            Invoke(new MethodInvoker(delegate { MessageBox.Show("You are not lead on the assigned study", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error); }));
                            return;
                        }
                    }
                }
                files = new List<string>();
                PnlPeople.Controls.Clear();
                foreach (string file in ofd.FileNames)
                {
                    files.Add(file);
                }
                lblFilesSelected.Text = files.Count.ToString() + " Files selected";
                if (files.Count > 0)
                {
                    lblHelper.Visible = true;
                    User n = new User();
                    var users = await n.getUsers();

                    int i = 0;
                    int y = 0;
                    foreach (UserProfile p in users)
                    {
                        i = i + 1;
                        SelectableUsers u = new SelectableUsers();
                        u.Location = new Point(1, -1 + y);
                        u.BackColor = Color.White;
                        u.BorderStyle = BorderStyle.Fixed3D;
                        u.Name = "ManageUser_" + i.ToString();
                        u.Size = new Size(187, 42);
                        u.Dock = DockStyle.Top;
                        u.TabIndex = i;
                        u.AddUsers(p, i);
                        PnlPeople.Controls.Add(u);
                        u.ButtonClick += new EventHandler(UserControl_ButtonClick);
                        y += u.Height;
                    }
                }
            }


        }

        protected async void UserControl_ButtonClick(object sender, EventArgs e)
        {
            List<Task> tasks = new List<Task>();
            foreach (string s in files)
            {
                tasks.Add(Task.Factory.StartNew(async () =>
                {
                    try
                    {
                        FileInfo fileInfo = new FileInfo(s);

                        UserFiles u = new UserFiles();
                        UserFile m = await u.getUserFile(s);
                        UserProfile Fileuser = await new User().getSubUser(m.UserID);
                        UserProfile SelectedProfile = await new User().getSubUser(((Button)sender).Text);
                        string sContents = EncDec.Decrypt(File.ReadAllText(fileInfo.FullName), Fileuser.PKey); ; ;
                        UserFile q = new UserFile();
                        q.FileContents = sContents;
                        q.FileLocation = fileInfo.FullName;
                        q.FileID = Guid.NewGuid();
                        q.DateTimeModified = DateTimeOffset.Now;
                        q.UserID = SelectedProfile.UserID;

                        File.WriteAllText(s, EncDec.Encrypt(sContents, SelectedProfile.PKey));
                        await new UserFiles().addFile(q);

                        FileInfo logInfo = new FileInfo(fileInfo.DirectoryName + "/Logs/" + fileInfo.Name.Split('.')[0] + ".log");

                        sContents = EncDec.Decrypt(File.ReadAllText(logInfo.FullName), Fileuser.PKey);
                        q.FileContents = sContents;
                        q.FileLocation = logInfo.FullName;
                        q.FileID = Guid.NewGuid();
                        q.DateTimeModified = DateTimeOffset.Now;
                        File.WriteAllText(s, EncDec.Encrypt(sContents, SelectedProfile.PKey));
                        await new UserFiles().addFile(q);

                        await new Log().addLog(new Logs
                        {
                            DateTimeLog = DateTimeOffset.Now,
                            Exception = GlobalVars._User.UserName + " (UserID:" + GlobalVars._User.UserID + ") reassigned + " + SelectedProfile.UserName + " (UserID:" + SelectedProfile.UserID + ") to file: " + fileInfo.FullName,
                            LogCategory = "Info",
                            LogID = Guid.NewGuid(),
                            UserID = GlobalVars._User.UserID,
                            LogPath = "",
                            msElapsed = -1
                        });
                    }
                    catch (Exception ex)
                    {

                    }
                }));


            }
            Task.WaitAll(tasks.ToArray());
            ToastForm toast = new ToastForm("Success", "File(s) encryption changed" );
            toast.Show();

        }
    }
}
