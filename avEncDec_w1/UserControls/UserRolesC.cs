using avEncDec_r1.Controllers;
using avEncDec_r1.Model;
using avEncDec_w1.UserControls.ManageUC;
using avEncDec_w1.UserControls.UserRolesUC;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Windows.Devices.WiFi;

namespace avEncDec_w1.UserControls
{
    public partial class UserRolesC : UserControl
    {
        static void SetDoubleBuffer(Control dgv, bool DoubleBuffered)
        {
            typeof(Control).InvokeMember("DoubleBuffered",
                BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.SetProperty,
                null, dgv, new object[] { DoubleBuffered });
        }
        public UserRolesC()
        {
            

            InitializeComponent();
          
            LoadData();
            pnlgvd.Enabled = false;
            pnlAdd.Enabled = false;
        }

        public List<UserProfile> users { get; private set; }
        public UserProfile selectedUser { get; set; }
        public async Task LoadData()
        {
            User n = new User();
            users = await n.getUsers();
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
                u.AddUsers(p,i);
                pnlUsers.Controls.Add(u);
                u.ButtonClick += new EventHandler(UserControl_ButtonClick);
                y += u.Height;
            }
           
        }
        protected async void UserControl_ButtonClick(object sender, EventArgs e)
        {
            lblHeader.Text = "User Role for " + ((Button)sender).Text;
            pnlgvd.Enabled = true;
            pnlAdd.Enabled = true;
            selectedUser = users[int.Parse(((Button)sender).Name.Split('_')[1].ToString()) - 1];
            await loadGridviewData(selectedUser);

        }

        private async Task loadGridviewData(UserProfile up)
        {
            pnlgvd.Controls.Clear();
            int i = 0;
            int y = 0;
            UserRoles n = new UserRoles();
            var b = await n.getAllUserRoles(up.UserID);
            b = b.Where(p=>p.isActive).ToList();
            foreach (UserRole p in b)
            {
                i = i + 1;
                PathRoles u = new PathRoles();
                u.Location = new Point(1, -1 + y);
                u.BackColor = Color.White;
                u.BorderStyle = BorderStyle.Fixed3D;
                u.Name = "PathRoles_" + i.ToString();
                u.Dock = DockStyle.Top;
                u.TabIndex = i;
                u.AddRole(p, i);
                pnlgvd.Controls.Add(u);
                u.ButtonClick += new EventHandler(UserControl_DeleteButtonClick);
                y += u.Height;
            }
        }
        protected async void UserControl_DeleteButtonClick(object sender, EventArgs e)
        {
            await loadGridviewData(selectedUser);

        }

        private async void btnAddPath_Click(object sender, EventArgs e)
        {
            DialogResult result = fbd.ShowDialog();

            if (result == DialogResult.OK && !string.IsNullOrWhiteSpace(fbd.SelectedPath))
            {
                lblPath.Text = fbd.SelectedPath;

                if(fbd.SelectedPath.Count(f=>f == '\\') == 5)
                {
                    UserRoles n = new UserRoles();
                    UserRole userRole = new UserRole();
                    userRole.RoleGUID = Guid.NewGuid(); ;
                    userRole.RoleCreatedDateTime = DateTimeOffset.Now;
                    userRole.CreatedByUserID = GlobalVars._User.UserID;
                    userRole.StudyPath = fbd.SelectedPath;
                    userRole.isActive = true;
                    userRole.UserID = selectedUser.UserID;
                    userRole.RoleOnStudy = "Lead";
                    await n.addUserRole(userRole);
                    await loadGridviewData(selectedUser);
                }
                else
                {
                    MessageBox.Show("Path must include, sponsor, study and timeline details", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }
    }
}
