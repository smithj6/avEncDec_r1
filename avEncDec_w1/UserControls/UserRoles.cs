using avEncDec_r1.Controllers;
using avEncDec_r1.Model;
using avEncDec_w1.UserControls.ManageUC;
using avEncDec_w1.UserControls.UserRolesUC;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace avEncDec_w1.UserControls
{
    public partial class UserRoles : UserControl
    {
        public UserRoles()
        {
            InitializeComponent();
            LoadData();
        }

        public List<UserProfile> users { get; private set; }

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
                u.TabIndex = i;
               
                u.AddUsers(p);
                pnlUsers.Controls.Add(u);

                u.ButtonClick += new EventHandler(UserControl_ButtonClick);
                y += u.Height;
            }



            //dgvUserfiles.DataSource = JsonConvert.DeserializeObject<DataTable>(JsonConvert.SerializeObject(b));
            // dgvUserfiles.Show();
        }
        protected void UserControl_ButtonClick(object sender, EventArgs e)
        {

          MessageBox.Show(  ((Button)sender).Text);
        }
    }
}
