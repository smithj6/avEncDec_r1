using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using avEncDec_r1.Controllers;
using avEncDec_r1.Model;
using Newtonsoft.Json;



namespace avEncDec_w1.UserControls
{
    public partial class DashBoard : UserControl
    {
        static void SetDoubleBuffer(Control dgv, bool DoubleBuffered)
        {
            typeof(Control).InvokeMember("DoubleBuffered",
                BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.SetProperty,
                null, dgv, new object[] { DoubleBuffered });
        }
        public DashBoard()
        {
            InitializeComponent();
           // dgvUserfiles.RowHeadersWidthSizeMode = DataGridViewRowHeadersWidthSizeMode.EnableResizing;
            // or even better, use .DisableResizing. Most time consuming enum is DataGridViewRowHeadersWidthSizeMode.AutoSizeToAllHeaders
            // set it to false if not needed
           // dgvUserfiles.RowHeadersVisible = false;
           // SetDoubleBuffer(dgvUserfiles, true);
            LoadData();


        }

        public async Task LoadData()
        {
            UserFiles n = new UserFiles();
            var i = await n.getAllUserFiles();
            var b = i.Where(p => p.UserID == GlobalVars._User.UserID).Select(x => new { x.FileLocation, x.DateTimeModified, x.UserID, CustomDate = CultureInfo.CurrentCulture.DateTimeFormat.GetMonthName(x.DateTimeModified.Month) +", "+ x.DateTimeModified.Year }).ToList();

            cBarFlesMonth.Series["Files"].Points.Clear();
            foreach (var item in b.GroupBy(q=>q.CustomDate).Select(q=> new { MetricName = q.Key, MetricCount = q.Count() }).OrderByDescending(q=>q.MetricName))
            {
                cBarFlesMonth.Series["Files"].Points.AddXY(item.MetricName,item.MetricCount);

            }



            //dgvUserfiles.DataSource = JsonConvert.DeserializeObject<DataTable>(JsonConvert.SerializeObject(b));
           // dgvUserfiles.Show();
        }
    }
}
