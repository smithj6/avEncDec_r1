using avEncDec_r1.Controllers;
using avEncDec_r1.Model;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace avEncDec_w1.UserControls.UserRolesUC
{
    public partial class PathRoles : UserControl
    {
        public UserRole _userRole { get; set; }
        public PathRoles()
        {
            InitializeComponent();
        }

        public void AddRole(UserRole userrole, int index)
        {
            lblPath.Text = userrole.StudyPath;
            lblLead.Text = userrole.RoleOnStudy;
            btnManage.Name = "btnManage_" + index;
            _userRole = userrole;
        }
        [Browsable(true)]
        [Category("Action")]
        [Description("Invoked when user clicks button")]
        public event EventHandler ButtonClick;
        private async void btnManage_Click(object sender, EventArgs e)
        {
            
            //bubble the event up to the parent
            if (this.ButtonClick != null)
            {
                UserRoles m = new UserRoles();
                await m.RemoveUserRole(_userRole);
                this.ButtonClick(sender, e);
            }
        }
    }
}
