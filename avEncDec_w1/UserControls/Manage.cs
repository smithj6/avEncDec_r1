using avEncDec_r1.Controllers;
using avEncDec_r1.Model;
using avEncDec_w1.UserControls.ManageUC;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;
using Windows.ApplicationModel.ConversationalAgent;
using Windows.System;

namespace avEncDec_w1.UserControls
{
    public partial class Manage : UserControl
    {
      
        public Manage()
        {
            
            InitializeComponent();
           
            LoadData();
          
        }

        public async Task LoadData()
        {

            avEncDec_r1.Controllers.User user = new avEncDec_r1.Controllers.User();
            GlobalVars._User = await user.checkUser();
            if(!GlobalVars._User.IsAdmin)
            {
                btnManageAdmins.Visible = false;
                button1.Visible = false;
            }
            pnlContent.Controls.Clear();
            TransferPrograms u = new TransferPrograms();

            u.BackColor = Color.Transparent;
            u.BorderStyle = BorderStyle.Fixed3D;
            u.Name = "TransferPrograms";
            u.Size = new Size(792, 50);

            u.Dock = DockStyle.Fill;
            pnlContent.Controls.Add(u);
           
        }

        
        private void btnTransferPrograms_Click(object sender, EventArgs e)
        {
            pnlContent.Controls.Clear();
            TransferPrograms u = new TransferPrograms();
            
            u.BackColor = Color.Transparent;
            u.BorderStyle = BorderStyle.Fixed3D;
            u.Name = "TransferPrograms";
            u.Size = new Size(792, 50);
          
            u.Dock = DockStyle.Fill;
            pnlContent.Controls.Add(u);

        }

        List<UserProfile> users = new List<UserProfile>();

        private async void btnManageAdmins_Click(object sender, EventArgs e)
        {
           pnlContent.Controls.Clear();
           avEncDec_r1.Controllers.User n = new avEncDec_r1.Controllers.User();
           users = await n.getUsers();
            users = users.Where(p => p.UserName != Environment.UserName).ToList();
            int i = 0;
            int y = 0;
            foreach (UserProfile p in users)
            {
                i = i + 1;
                ManageUser u = new ManageUser();
                u.Location = new Point(1, -1 + y);
                u.BackColor = Color.White;
                u.BorderStyle = BorderStyle.Fixed3D;
                u.Name = "ManageUser_" + i.ToString();
                u.Size = new Size(792, 50);
                u.TabIndex = i;
                u.Dock = DockStyle.Top;

                u.AddUsers(p);
                pnlContent.Controls.Add(u);
                y += u.Height;
            }
          
        }

        private void button1_Click(object sender, EventArgs e)
        {
            pnlContent.Controls.Clear();
            UserRolesC u = new UserRolesC();

            u.BackColor = Color.Transparent;
            u.BorderStyle = BorderStyle.Fixed3D;
            u.Name = "UserRolesC";
            u.Size = new Size(792, 50);
            u.BackColor = Color.FromArgb(46, 51, 73);

            u.Dock = DockStyle.Fill;
            pnlContent.Controls.Add(u);
        }

      
    }
}
