using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace avEncDec_w1.Toasts
{
    public partial class ToastForm : Form
    {
        int ToastX,ToastY;
        public ToastForm(string Type, string Message)
        {
            InitializeComponent();

            lblType .Text = Type;
            lblMessage .Text = Message;
        }

        private void ToastForm_Load(object sender, EventArgs e)
        {
            Position();
        }

        private void tmrToast_Tick(object sender, EventArgs e)
        {
            ToastY -= 10;
            this.Location = new Point(ToastX, ToastY);
            if(ToastY<= Screen.PrimaryScreen.WorkingArea.Height-60)
            {
                tmrToast.Stop();
                tmrKillToast.Start();
            }
        }
        int  y =100;
        private void tmrKillToast_Tick(object sender, EventArgs e)
        {
            y--;
            if(y<=0)
            {
                ToastY += 10;
                this.Location = new Point(ToastX,ToastY);
                if(ToastY > Screen.PrimaryScreen.WorkingArea.Height +70)
                {
                    tmrKillToast.Stop();
                    y = 100;
                    this.Close();
                }
            }

        }

        private void Position()
        {
            int ScreenWidth     = Screen.PrimaryScreen.WorkingArea.Width;
            int ScreenHeight    = Screen.PrimaryScreen.WorkingArea.Height;

            ToastX = ScreenWidth - this.Width-5;
            ToastY = ScreenHeight - this.Height+70;

            this.Location = new Point(ToastX, ToastY);
        }
    }
}
