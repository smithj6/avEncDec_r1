using avEncDec_r1.Model;
using avEncDec_r1.Controllers;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using avEncDec_w1.Toasts;


namespace avEncDec_w1.UserControls.ManageUC
{
    public partial class ManageUser : UserControl
    {
        private UserProfile _profile;
        private bool _run = false;
        public ManageUser()
        {
            InitializeComponent();
        }
        public void AddUsers(UserProfile profile)
        {
            lblUserName.Text = profile.UserName;
            isActive.Checked = profile.isActive;
            isAdmin.Checked = profile.IsAdmin;
            _profile = profile;
            _run = true;
        }

        private void isActive_CheckedChanged(object sender, EventArgs e)
        {

        }

        private void isAdmin_CheckedChanged(object sender, EventArgs e)
        {
            if (!_run) return;
            User n = new User();
            n.setUserAdmin(_profile.UserName,GlobalVars._User,isAdmin.Checked);
            ToastForm toast = new ToastForm("Success","Admin grants updated");
            toast.Show();
          
        }

        private void ManageUser_Load(object sender, EventArgs e)
        {

        }
       

        private void btnMangeUser_Click(object sender, EventArgs e)
        {
            //UserRoleForm roleForm = new UserRoleForm(_profile);
            //roleForm.Show();
        }
    }
}
