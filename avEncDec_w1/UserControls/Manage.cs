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
using System.Threading.Tasks;
using System.Windows.Forms;
using Windows.ApplicationModel.ConversationalAgent;

namespace avEncDec_w1.UserControls
{
    public partial class Manage : UserControl
    {
        List<UserProfile> users = new List<UserProfile>();
        public Manage()
        {
            InitializeComponent();
            LoadData();
        }

        public async Task LoadData()
        {
            User n = new User();
            users = await n.getUsers();

            int i = 0;
            int y = 0;
            foreach (UserProfile p in users)
            {
                i = i+ 1;
                ManageUser u = new ManageUser();
                u.Location = new Point(1,-1+ y);
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

        private void U_FontChanged(object sender, EventArgs e)
        {
            throw new NotImplementedException();
        }
    }
}
