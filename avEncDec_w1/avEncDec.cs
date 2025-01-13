using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using avEncDec_r1.Controllers;
using avEncDec_r1.Model;
using avEncDec_w1.UserControls;



namespace avEncDec_w1
{


    public partial class avEncDec : Form
    {
        NavigationControl navigationControl;
        public avEncDec()
        {
            InitializeComponent();
            ChangeNavClick((Button)btnDashboard);

            LoadData();
            InitializeNavigationControl();
        }
        public async Task LoadData()
        {
            User user = new User();
            GlobalVars._User = await user.checkUser();
            label1.Text = GlobalVars._User.UserName;
        }
        private void InitializeNavigationControl()
        {
            List<UserControl> userControls = new List<UserControl>()
            {
                new DashBoard(),
                new Manage()
            };
            navigationControl = new NavigationControl(userControls, panel3);
            navigationControl.Display(0);
        }
        private void btnDashboard_Click(object sender, EventArgs e)
        {
            ChangeNavClick((Button)sender);
            navigationControl.Display(0);

        }

        private void ChangeNavClick(Button sender)
        {
            foreach (var button in panel1.Controls.OfType<Button>())
            {
                button.BackColor = Color.FromArgb(24, 30, 54);
            }
            //label2.Text = sender.Text;
            pnlNav.Height = sender.Height;
            pnlNav.Top = sender.Top;
            pnlNav.Left = sender.Left;
            sender.BackColor = Color.FromArgb(46, 51, 73);
        }



        private void btnManage_Click(object sender, EventArgs e)
        {
            ChangeNavClick((Button)sender);
            navigationControl.Display(1);
        }

        private void btnLogs_Click(object sender, EventArgs e)
        {
            ChangeNavClick((Button)sender);
        }

        private void btnAnalytics_Click(object sender, EventArgs e)
        {
            ChangeNavClick((Button)sender);
        }

        private void btnSettings_Click(object sender, EventArgs e)
        {
            ChangeNavClick((Button)sender);
        }
        private void btnBatchRun_Click(object sender, EventArgs e)
        {
            ChangeNavClick((Button)sender);
        }

        private void btnTransfer_Click(object sender, EventArgs e)
        {
            ChangeNavClick((Button)sender);
        }

        private void btnLogsCheck_Click(object sender, EventArgs e)
        {
            ChangeNavClick((Button)sender);
        }
    }
}
