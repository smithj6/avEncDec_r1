using avEncDec_r1.Model;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Reflection.Emit;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace avEncDec_w1.UserControls.ManageUC
{
    public partial class UserRoleForm : Form
    {
        private UserProfile _userProfile;
        public UserRoleForm(UserProfile userProfile)
        {
            InitializeComponent();
            _userProfile = userProfile;
            lblHeader.Anchor = System.Windows.Forms.AnchorStyles.Bottom;
            lblHeader.AutoSize = true;
            lblHeader.TextAlign = System.Drawing.ContentAlignment.MiddleCenter;
            lblHeader.Text += " " + userProfile.UserName; 
           
        }

        private void btnAdd_Click(object sender, EventArgs e)
        {
            
        }
    }
}
