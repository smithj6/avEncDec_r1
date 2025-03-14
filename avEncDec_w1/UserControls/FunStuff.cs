using avEncDec_w1.UserControls.FunStuffUC;
using avEncDec_w1.UserControls.ManageUC;
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
    public partial class FunStuff : UserControl
    {
        public FunStuff()
        {
            InitializeComponent();
            LoadData();
        }
        public  void LoadData()
        {
            pnlContent.Controls.Clear();
            LogCheck u = new LogCheck();

            u.BackColor = Color.Transparent;
            u.BorderStyle = BorderStyle.Fixed3D;
            u.Name = "LogCheck";
            u.Size = new Size(792, 50);

            u.Dock = DockStyle.Fill;
            pnlContent.Controls.Add(u);
        }
        private void btnLogCheck_Click(object sender, EventArgs e)
        {
         LoadData();
        }

        private void btnBatchRun_Click(object sender, EventArgs e)
        {
            pnlContent.Controls.Clear();
            BatchRun u = new BatchRun();

            u.BackColor = Color.Transparent;
            u.BorderStyle = BorderStyle.Fixed3D;
            u.Name = "BatchRun";
            u.Size = new Size(792, 50);

            u.Dock = DockStyle.Fill;
            pnlContent.Controls.Add(u);
        }

        private void btnTransfer_Click(object sender, EventArgs e)
        {
            pnlContent.Controls.Clear();
            ExportM5 u = new ExportM5();

            u.BackColor = Color.Transparent;
            u.BorderStyle = BorderStyle.Fixed3D;
            u.Name = "ExportM5";
            u.Size = new Size(792, 50);

            u.Dock = DockStyle.Fill;
            pnlContent.Controls.Add(u);
        }

        private void btnTransferSOP_Click(object sender, EventArgs e)
        {
            pnlContent.Controls.Clear();
            TransferSOP u = new TransferSOP();

            u.BackColor = Color.Transparent;
            u.BorderStyle = BorderStyle.Fixed3D;
            u.Name = "TransferSOP";
            u.Size = new Size(792, 50);

            u.Dock = DockStyle.Fill;
            pnlContent.Controls.Add(u);
        }
    }
}
