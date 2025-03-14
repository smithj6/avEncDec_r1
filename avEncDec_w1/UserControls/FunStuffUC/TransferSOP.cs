using avEncDec_r1.Controllers;
using avEncDec_r1;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using static avEncDec_w1.UserControls.FunStuffUC.ExportM5;
using avEncDec_r1.Model;
using System.Security.Cryptography;
using avEncDec_w1.Toasts;

namespace avEncDec_w1.UserControls.FunStuffUC
{
    public partial class TransferSOP : UserControl
    {
        public TransferSOP()
        {
            InitializeComponent();
        }
        public List<string> TransferList { get; set; } = new List<string>();
        private async void btnDoLogs_Click(object sender, EventArgs e)
        {
            btnDoTransferSOP.Enabled = false;
            DialogResult res = fbdPath.ShowDialog(this);
            string datetime = (DateTime.Now.ToString("ddMMMyyyy")).ToUpper();
            List<filesToCopy> Files = new List<filesToCopy>();
            List<Task> Tasks = new List<Task>();
            if (res == DialogResult.OK)
            {
                if (fbdPath.SelectedPath.Split('\\').Count() != 6)
                {
                    MessageBox.Show("Please make sure the path is correctly selected", "Path error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    return;
                }
                TransferList.Add(fbdPath.SelectedPath + @"\SOP\" + datetime + @"\03 Interim Raw Datasets\");    //0
                TransferList.Add(fbdPath.SelectedPath + @"\SOP\" + datetime + @"\04 Interim Programs\sdtm\");    //1
                TransferList.Add(fbdPath.SelectedPath + @"\SOP\" + datetime + @"\04 Interim Programs\adam\");    //2
                TransferList.Add(fbdPath.SelectedPath + @"\SOP\" + datetime + @"\05 Interim Datasets\");        //3
                TransferList.Add(fbdPath.SelectedPath + @"\SOP\" + datetime + @"\06 Interim Output\");          //4

                TransferList.Add(fbdPath.SelectedPath + @"\SOP\" + datetime + @"\07 Final Raw Datasets\");      //5
                TransferList.Add(fbdPath.SelectedPath + @"\SOP\" + datetime + @"\08 Final Programs\sdtm\");     //6
                TransferList.Add(fbdPath.SelectedPath + @"\SOP\" + datetime + @"\08 Final Programs\adam\");     //7
                TransferList.Add(fbdPath.SelectedPath + @"\SOP\" + datetime + @"\08 Final Programs\");          //8
                TransferList.Add(fbdPath.SelectedPath + @"\SOP\" + datetime + @"\09 Final Datasets\");          //9
                TransferList.Add(fbdPath.SelectedPath + @"\SOP\" + datetime + @"\10 Final Output\");            //10

                TransferList.Add(fbdPath.SelectedPath + @"\SOP\" + datetime + @"\04 Interim Programs\sdtm\Specifications\");    //11
                TransferList.Add(fbdPath.SelectedPath + @"\SOP\" + datetime + @"\08 Final Programs\sdtm\Specifications\");     //12

                TransferList.Add(fbdPath.SelectedPath + @"\SOP\" + datetime + @"\04 Interim Programs\adam\Specifications\");    //13
                TransferList.Add(fbdPath.SelectedPath + @"\SOP\" + datetime + @"\08 Final Programs\adam\Specifications\");     //14

                TransferList.Add(fbdPath.SelectedPath + @"\SOP\" + datetime + @"\04 Interim Programs\");                        //15

                TransferList.Add(TransferList[3] + @"ADaM\");       //16
                TransferList.Add(TransferList[9] + @"ADaM\");       //17

                TransferList.Add(TransferList[3] + @"SDTM\");       //18
                TransferList.Add(TransferList[9] + @"SDTM\");       //19

                TransferList.Add(TransferList[3] + @"TFL\");       //20
                TransferList.Add(TransferList[9] + @"TFL\");       //21

                TransferList.Add(TransferList[3] + @"TFL\");       //20
                TransferList.Add(TransferList[9] + @"TFL\");       //21

                TransferList.Add(fbdPath.SelectedPath + @"\SOP\" + datetime + @"\04 Interim Programs\Tables\");                        //15
                TransferList.Add(fbdPath.SelectedPath + @"\SOP\" + datetime + @"\04 Interim Programs\Listings\");                        //15
                TransferList.Add(fbdPath.SelectedPath + @"\SOP\" + datetime + @"\04 Interim Programs\Figures\");                        //15

                TransferList.Add(fbdPath.SelectedPath + @"\SOP\" + datetime + @"\08 Final Programs\Tables\");          //8
                TransferList.Add(fbdPath.SelectedPath + @"\SOP\" + datetime + @"\08 Final Programs\Listings\");          //8
                TransferList.Add(fbdPath.SelectedPath + @"\SOP\" + datetime + @"\08 Final Programs\Figures\");          //8

                foreach (var i in TransferList)
                    Directory.CreateDirectory(i);


                foreach (var i in Directory.GetFiles(fbdPath.SelectedPath + @"\02_SourceData\", "*.sas7bdat"))
                {
                    Tasks.Add(new TaskFactory().StartNew(() => {
                        File.Copy(i, TransferList[0]);
                        File.Copy(i, TransferList[5]);
                    }));
                }

                foreach(var i in Directory.GetFiles(fbdPath.SelectedPath + @"\08_Final Programs\02_CDISC\Production\01_SDTM\", "*.sas"))
                {
                    Tasks.Add(new TaskFactory().StartNew(async () => {
                        FileInfo n = new FileInfo(i);
                        var b = await new UserFiles().getUserFile(i);
                        if (b != null)
                        {
                            var c = await new User().getSubUser(b.UserID);
                            File.WriteAllText(TransferList[1] + n.Name, EncDec.Decrypt(File.ReadAllText(i), c.PKey));
                            File.WriteAllText(TransferList[6] + n.Name, EncDec.Decrypt(File.ReadAllText(i), c.PKey));
                        }
                        else
                        {
                            File.Copy(i, TransferList[1], true);
                            File.Copy(i, TransferList[6], true);
                        }
                    }));
                }

                foreach (var i in Directory.GetFiles(fbdPath.SelectedPath + @"\01_Specifications\01_SDTM\", "*.xlsx"))
                {
                    Tasks.Add(new TaskFactory().StartNew(() => {
                        File.Copy(i, TransferList[11]);
                        File.Copy(i, TransferList[12]);
                    }));
                }

                foreach (var i in Directory.GetFiles(fbdPath.SelectedPath + @"\08_Final Programs\02_CDISC\Production\02_ADaM", "*.sas"))
                {
                    Tasks.Add(new TaskFactory().StartNew(async () => {
                        FileInfo n = new FileInfo(i);
                        var b = await new UserFiles().getUserFile(i);
                        if (b != null)
                        {
                            var c = await new User().getSubUser(b.UserID);
                            File.WriteAllText(TransferList[1] + n.Name, EncDec.Decrypt(File.ReadAllText(i), c.PKey));
                            File.WriteAllText(TransferList[6] + n.Name, EncDec.Decrypt(File.ReadAllText(i), c.PKey));
                        }
                        else
                        {
                            File.Copy(i, TransferList[1], true);
                            File.Copy(i, TransferList[6], true);
                        }
                    }));
                }

                foreach (var i in Directory.GetFiles(fbdPath.SelectedPath + @"\01_Specifications\02_ADaM\", "*.xlsx"))
                {
                    Tasks.Add(new TaskFactory().StartNew(() => {
                        File.Copy(i, TransferList[13]);
                        File.Copy(i, TransferList[14]);
                    }));
                }

                foreach (var i in Directory.GetFiles(fbdPath.SelectedPath + @"\08_Final Programs\03_TFL\Production\Tables\", "*.sas"))
                {
                    Tasks.Add(new TaskFactory().StartNew(async () => {
                        FileInfo n = new FileInfo(i);
                        var b = await new UserFiles().getUserFile(i);
                        if (b != null)
                        {
                            var c = await new User().getSubUser(b.UserID);
                            File.WriteAllText(TransferList[15]+@"/Tables/" + n.Name, EncDec.Decrypt(File.ReadAllText(i), c.PKey));
                            File.WriteAllText(TransferList[8] + @"/Tables/" + n.Name, EncDec.Decrypt(File.ReadAllText(i), c.PKey));
                        }
                        else
                        {
                            File.Copy(i, TransferList[15] + @"/Tables/", true);
                            File.Copy(i, TransferList[8] + @"/Tables/", true);
                        }
                    }));
                }

                foreach (var i in Directory.GetFiles(fbdPath.SelectedPath + @"\08_Final Programs\03_TFL\Production\Listings\", "*.sas"))
                {
                    Tasks.Add(new TaskFactory().StartNew(async () => {
                        FileInfo n = new FileInfo(i);
                        var b = await new UserFiles().getUserFile(i);
                        if (b != null)
                        {
                            var c = await new User().getSubUser(b.UserID);
                            File.WriteAllText(TransferList[15] + @"/Listings/" + n.Name, EncDec.Decrypt(File.ReadAllText(i), c.PKey));
                            File.WriteAllText(TransferList[8] + @"/Listings/" + n.Name, EncDec.Decrypt(File.ReadAllText(i), c.PKey));
                        }
                        else
                        {
                            File.Copy(i, TransferList[15] + @"/Listings/", true);
                            File.Copy(i, TransferList[8] + @"/Listings/", true);
                        }
                    }));
                }

                foreach (var i in Directory.GetFiles(fbdPath.SelectedPath + @"\08_Final Programs\03_TFL\Production\Figures\", "*.sas"))
                {
                    Tasks.Add(new TaskFactory().StartNew(async () => {
                        FileInfo n = new FileInfo(i);
                        var b = await new UserFiles().getUserFile(i);
                        if (b != null)
                        {
                            var c = await new User().getSubUser(b.UserID);
                            File.WriteAllText(TransferList[15] + @"/Figures/" + n.Name, EncDec.Decrypt(File.ReadAllText(i), c.PKey));
                            File.WriteAllText(TransferList[8] + @"/Figures/" + n.Name, EncDec.Decrypt(File.ReadAllText(i), c.PKey));
                        }
                        else
                        {
                            File.Copy(i, TransferList[15] + @"/Figures/", true);
                            File.Copy(i, TransferList[8] + @"/Figures/", true);
                        }
                    }));
                }

                foreach (var i in Directory.GetFiles(fbdPath.SelectedPath + @"\03_Production\01_SDTM\", "*.sas7bdat"))
                {
                    Tasks.Add(new TaskFactory().StartNew(() => {
                        File.Copy(i, TransferList[18], true);
                        File.Copy(i, TransferList[19], true);
                    }));
                }

                foreach (var i in Directory.GetFiles(fbdPath.SelectedPath + @"\03_Production\02_ADaM\", "*.sas7bdat"))
                {
                    Tasks.Add(new TaskFactory().StartNew(() => {
                        File.Copy(i, TransferList[16],true);
                        File.Copy(i, TransferList[17], true);
                    }));
                }

                foreach (var i in Directory.GetFiles(fbdPath.SelectedPath + @"\03_Production\03_TFL\", "*.sas7bdat"))
                {
                    Tasks.Add(new TaskFactory().StartNew(() => {
                        File.Copy(i, TransferList[20], true);
                        File.Copy(i, TransferList[21], true);
                    }));
                }

                foreach (var i in Directory.GetFiles(fbdPath.SelectedPath + @"\05_OutputDocs\01_RTF\", "*.rtf"))
                {
                    Tasks.Add(new TaskFactory().StartNew(() => {
                        File.Copy(i, TransferList[4], true);
                        File.Copy(i, TransferList[10], true);
                    }));
                }

                foreach (var i in Directory.GetFiles(fbdPath.SelectedPath + @"\05_OutputDocs\07_PDF\", "*.pdf"))
                {
                    Tasks.Add(new TaskFactory().StartNew(() => {
                        File.Copy(i, TransferList[4], true);
                        File.Copy(i, TransferList[10], true);
                    }));
                }



                Task.WaitAll(Tasks.ToArray());

                await new Log().addLog(new Logs
                {
                    DateTimeLog = DateTimeOffset.Now,
                    Exception = GlobalVars._User.UserName + " (UserID:" + GlobalVars._User.UserID + ") done with TransferSOP run on: " + fbdPath.SelectedPath,
                    LogCategory = "Info",
                    LogID = Guid.NewGuid(),
                    UserID = GlobalVars._User.UserID,
                    LogPath = "",
                    msElapsed = -1
                });

                ToastForm toast = new ToastForm("Success", "SOP done");
                toast.Show();
            }
            btnDoTransferSOP.Enabled = true;
        }
    }
}
