using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace avEncDec_w1
{
    public class NavigationControl
    {
        List<UserControl> userControlList = new List<UserControl>();
        Panel panel;

        public NavigationControl(List<UserControl> userControlList, Panel panel)
        {
            this.userControlList = userControlList;
            this.panel = panel;
            AddUserControls();
        }
        private void AddUserControls()
        {
            foreach (var userControl in userControlList)
            {
                userControl.Dock = DockStyle.Fill;
                panel.Controls.Add(userControl);
            }
        }
        public void Display(int index)
        {
            if (index < userControlList.Count)
            {
                userControlList[index].BringToFront();
            }
        }
    }
}
