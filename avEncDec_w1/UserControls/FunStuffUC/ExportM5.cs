using avEncDec_r1;
using avEncDec_r1.Controllers;
using avEncDec_r1.Model;
using avEncDec_w1.Toasts;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using Windows.Devices.WiFiDirect;

namespace avEncDec_w1.UserControls.FunStuffUC
{
    public partial class ExportM5 : UserControl
    {
        public ExportM5()
        {
            InitializeComponent();
        }
        public class filesToCopy
        {
            public string sourceFile { get; set; }
            public string destinationFile { get; set; }
        }

        private async void btnDoExportM5_Click(object sender, EventArgs e)
        {
            btnDoExportM5.Enabled = false;
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

                string sdtm = fbdPath.SelectedPath + @"\M5\" + datetime + @"\datasets\" + fbdPath.SelectedPath.Split('\\')[2] + @"\tabulations\sdtm\";
                string datasets = fbdPath.SelectedPath + @"\M5\" + datetime + @"\datasets\" + fbdPath.SelectedPath.Split('\\')[2] + @"\analysis\adam\datasets\";
                string programs = fbdPath.SelectedPath + @"\M5\" + datetime + @"\datasets\" + fbdPath.SelectedPath.Split('\\')[2] + @"\analysis\adam\programs\";
                Directory.CreateDirectory(datasets);
                Directory.CreateDirectory(programs);
                Directory.CreateDirectory(sdtm);

                Files.Add(new filesToCopy() { sourceFile = fbdPath.SelectedPath + @"\01_Specifications\04_SDTM_aCRF\aCRF.pdf", destinationFile = sdtm });
                Files.Add(new filesToCopy() { sourceFile = fbdPath.SelectedPath + @"\06_Define\SDTM\OUTPUT\csdrg.docx", destinationFile = sdtm });
                Files.Add(new filesToCopy() { sourceFile = fbdPath.SelectedPath + @"\06_Define\SDTM\OUTPUT\csdrg.pdf", destinationFile = sdtm });
                Files.Add(new filesToCopy() { sourceFile = fbdPath.SelectedPath + @"\06_Define\SDTM\OUTPUT\define.xml", destinationFile = sdtm });

                foreach (var i in Directory.GetFiles(fbdPath.SelectedPath + @"\06_Define\SDTM\OUTPUT\", "*.xsl"))
                {
                    Files.Add(new filesToCopy() { sourceFile = i, destinationFile = sdtm });
                }
                foreach (var i in Directory.GetFiles(fbdPath.SelectedPath + @"\03_Production\01_SDTM\01_XPT\", "*.xpt"))
                {
                    Files.Add(new filesToCopy() { sourceFile = i, destinationFile = sdtm });
                }
                Files.Add(new filesToCopy() { sourceFile = fbdPath.SelectedPath + @"\06_Define\ADAM\OUTPUT\adrg.docx", destinationFile = datasets });
                Files.Add(new filesToCopy() { sourceFile = fbdPath.SelectedPath + @"\06_Define\ADAM\OUTPUT\adrg.pdf", destinationFile = datasets });

                Files.Add(new filesToCopy() { sourceFile = fbdPath.SelectedPath + @"\06_Define\ADAM\OUTPUT\define.xml", destinationFile = datasets });
                foreach (var i in Directory.GetFiles(fbdPath.SelectedPath + @"\06_Define\ADAM\OUTPUT\", "*.xsl"))
                {
                    Files.Add(new filesToCopy() { sourceFile = i, destinationFile = datasets });
                }
                foreach (var i in Directory.GetFiles(fbdPath.SelectedPath + @"\03_Production\02_ADaM\01_XPT\", "*.xpt"))
                {
                    Files.Add(new filesToCopy() { sourceFile = i, destinationFile = datasets });
                }

                foreach (var i in Directory.GetFiles(fbdPath.SelectedPath + @"\08_Final Programs\02_CDISC\Production\02_ADaM\", "*.sas"))
                {
                    Files.Add(new filesToCopy() { sourceFile = i, destinationFile = programs });
                }
                foreach (var i in Directory.GetFiles(fbdPath.SelectedPath + @"\08_Final Programs\\03_TFL\Production\Listings\", "*.sas"))
                {
                    Files.Add(new filesToCopy() { sourceFile = i, destinationFile = programs });
                }
                foreach (var i in Directory.GetFiles(fbdPath.SelectedPath + @"\08_Final Programs\\03_TFL\Production\Tables\", "*.sas"))
                {
                    Files.Add(new filesToCopy() { sourceFile = i, destinationFile = programs });
                }
                foreach (var i in Directory.GetFiles(fbdPath.SelectedPath + @"\08_Final Programs\\03_TFL\Production\Figures\", "*.sas"))
                {
                    Files.Add(new filesToCopy() { sourceFile = i, destinationFile = programs });
                }

                foreach (var i in Files)
                {
                    Tasks.Add(new TaskFactory().StartNew(async () =>
                    {
                        if (File.Exists(i.sourceFile))
                        {
                            FileInfo n = new FileInfo(i.sourceFile);
                            var b = await new UserFiles().getUserFile(i.sourceFile);
                            if (b != null)
                            {
                                var c = await new User().getSubUser(b.UserID);
                                File.WriteAllText(i.destinationFile + n.Name, EncDec.Decrypt(File.ReadAllText(i.sourceFile), c.PKey));
                            }
                            else
                            {
                                File.Copy(i.sourceFile, i.destinationFile, true);
                            }
                        }

                    }));
                }

                Task.WaitAll(Tasks.ToArray());

                foreach (var i in Directory.GetFiles(programs,"*.sas"))
                {
                   string n = Path.ChangeExtension(i, ".txt");
                    File.Move(i, n);
                }
                await new Log().addLog(new Logs
                {
                    DateTimeLog = DateTimeOffset.Now,
                    Exception = GlobalVars._User.UserName + " (UserID:" + GlobalVars._User.UserID + ") done a M5 transfer on: " + fbdPath.SelectedPath,
                    LogCategory = "Info",
                    LogID = Guid.NewGuid(),
                    UserID = GlobalVars._User.UserID,
                    LogPath = "",
                    msElapsed = -1
                });
                ToastForm toast = new ToastForm("Success", "M5 done");
                toast.Show();
            }
            btnDoExportM5.Enabled = true;

        }
    }
}
