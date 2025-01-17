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
using Windows.UI.Xaml.Documents;

namespace avEncDec_w1.UserControls.UserRolesUC
{
    public partial class SelectableUsers : UserControl
    {
        public SelectableUsers()
        {
            InitializeComponent();
        }
        public void AddUsers(UserProfile profile)
        {
            btnUser.Text = profile.UserName;
          
        }
        [Browsable(true)]
        [Category("Action")]
        [Description("Invoked when user clicks button")]
        public event EventHandler ButtonClick;
        private void btnUser_Click(object sender, EventArgs e)
        {
            //bubble the event up to the parent
            if (this.ButtonClick != null)
            {
                this.ButtonClick(sender, e);
            }
        }
    }
}
