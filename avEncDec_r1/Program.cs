
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using avEncDec_r1.Model;
using Microsoft.Toolkit.Uwp.Notifications;
using Newtonsoft.Json;
using avEncDec_r1.Controllers;
using System.Security.Cryptography;
using Windows.Security.Cryptography.Certificates;
using Windows.UI.Xaml.Media.Animation;
using CsvHelper;
using System.Globalization;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.TrackBar;

namespace avEncDec_r1
{
    internal class Program
    {
        public static string tempFolder = @"C:\sas_temp\";
        static string SASHOME = "C:\\Program Files\\SASHome\\SASFoundation\\9.4\\sas.exe\" -CONFIG \"C:\\Program Files\\SASHome\\SASFoundation\\9.4\\nls\\u8\\sasv9.cfg";
        static string MEH = @"::@echo off CALL ""C:\Program Files\SASHome\SASFoundation\9.4\sas.exe""  -SYSIN ""C:\Users\Tiaan.Van der Spuy\Desktop\Terminator\Terminator\bin\Release\Files\0ac92d52bcde.sas"" -PRINT 'R:\StatWorks\01_Master folder\nataliag\0ac92d52bcde.output' -LOG 'R:\StatWorks\01_Master folder\nataliag\0ac92d52bcde.log' -ICON -NOSPLASH";
        public static int convesationID = 0;
        private static UserProfile user { get; set; }

        [DllImport("User32.dll", CallingConvention = CallingConvention.StdCall, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool ShowWindow([In] IntPtr hWnd, [In] int nCmdShow);


        static async Task Main(string[] args)
        {
            if (args.Length == 0)
            {
                return;
            }
            IntPtr handle = Process.GetCurrentProcess().MainWindowHandle;
            ShowWindow(handle, 6);
            user = await new User().checkUser();
            if (args.Length == 1)
            {
                Random rnd = new Random();
                convesationID = rnd.Next(1, 100000);

                CheckIfDirExistAndCreatesIt();

                //args = new []{ @"T:\SAB Biotherapeutics Inc\SAB-142-101\11 Stats\03 Analysis\Draft 2\08_Final Programs\02_CDISC\Production\01_SDTM\ae.sas"};

                if (args.Length == 1)
                {
                    FileInfo n = new FileInfo(args[0]);
                    if (n.FullName.Contains("02_CDISC") || n.FullName.Contains("03_TFL"))
                    {
                        string tempFilePath = await CopyFileToTempAsync(n, tempFolder);
                        await StartSASProcess(tempFilePath);
                        //Do all of the DB checks
                        maintainDB(n.FullName, tempFilePath);
                        //Check if instance is all ready running then stop it
                        if (System.Diagnostics.Process.GetProcessesByName(System.IO.Path.GetFileNameWithoutExtension(System.Reflection.Assembly.GetEntryAssembly().Location)).Count() > 1) System.Diagnostics.Process.GetCurrentProcess().Kill();
                        await Task.Run(() => MonitorFileAsync());
                        Console.ReadLine();
                    }
                    else
                    {
                        await StartSASProcess(n.FullName);
                    }
                }
                else
                {
                    await ShowNotification("No file has been found");
                }
            }
            else
            {

                if (args[0] == "trans")
                {
                    string locFile      = args[1];
                    string destination  = args[2];
                    string DecEnc       = args[3];
                    FileInfo n = new FileInfo(args[0]);
                    if (n.FullName.Contains("02_CDISC") || n.FullName.Contains("03_TFL"))
                    {
                        var b = await new UserFiles().getUserFile(locFile);
                        if (b != null)
                        {
                            UserFile q = new UserFile()
                            {
                                DateTimeModified = DateTimeOffset.Now,
                                FileContents = b.FileContents,
                                FileID = Guid.NewGuid(),
                                FileLocation = destination,
                                UserID = b.UserID
                            };

                            await new UserFiles().addFile(q);
                            if (DecEnc == "Enc")
                            {
                                File.Copy(locFile, destination, true);
                                await new Log().addLog(new Logs
                                {
                                    DateTimeLog = DateTimeOffset.Now,
                                    Exception = user.UserName + " (UserID:" + user.UserID + ") did a encrypted transfer from: " + locFile + " to: " + destination,
                                    LogCategory = "Info",
                                    LogID = Guid.NewGuid(),
                                    UserID = user.UserID,
                                    LogPath = "",
                                    msElapsed = -1
                                });
                            }
                            if (DecEnc == "Dec")
                            {
                                var c = await new User().getSubUser(b.UserID);
                                File.WriteAllText(destination, EncDec.Decrypt(File.ReadAllText(locFile), c.PKey));
                                await new Log().addLog(new Logs
                                {
                                    DateTimeLog = DateTimeOffset.Now,
                                    Exception = user.UserName + " (UserID:" + user.UserID + ") did a decrypted transfer from: " + locFile + " to: " + destination,
                                    LogCategory = "Warning",
                                    LogID = Guid.NewGuid(),
                                    UserID = user.UserID,
                                    LogPath = "",
                                    msElapsed = -1
                                });

                            }
                        }
                        else
                        {
                            File.Copy(locFile, destination, true);

                            await new Log().addLog(new Logs
                            {
                                DateTimeLog = DateTimeOffset.Now,
                                Exception = user.UserName + " (UserID:" + user.UserID + ") did a file copy transfer from: " + locFile + " to: " + destination,
                                LogCategory = "Info",
                                LogID = Guid.NewGuid(),
                                UserID = user.UserID,
                                LogPath = "",
                                msElapsed = -1
                            });
                        }
                    }
                }
            }
        }

        static void maintainDB(string sourceFilePath, string destinationPath)
        {
            FileInfo _localdb = new FileInfo(@"C:/sas_temp/locdb.lol");
            //actual .sas file
            FileInfo sourceFile             = new FileInfo(sourceFilePath);
            FileInfo destionFile            = new FileInfo(destinationPath);   
            Model.FileHooker fileHooker     = new Model.FileHooker();
            fileHooker.Guid                 = Guid.NewGuid();
            fileHooker.MainFile             = sourceFile.FullName;
            fileHooker.LinkedFile           = destionFile.FullName;
            fileHooker.DTOFile              = DateTimeOffset.Now;
            

            var fileHookers = new List<Model.FileHooker>();
            if (_localdb.Length > 0)
            {
                 fileHookers = JsonConvert.DeserializeObject<List<Model.FileHooker>>(EncDec.Decrypt(File.ReadAllText(@"C:/sas_temp/locdb.lol"), user.PKey));
            }
            fileHookers.Add(fileHooker);
            ////link up .log file.
            //fileHooker.MainFile = fileHooker.LinkedFile = sourceFile.DirectoryName + @"\logs\" + sourceFile.Name.Replace(".sas",".log");
            //fileHookers.Add(fileHooker);

            fileHookers = fileHookers.GroupBy(x => x.MainFile).Select(g => g.OrderByDescending(o => o.DTOFile).First()).ToList();
            System.IO.File.WriteAllText(@"C:/sas_temp/locdb.lol", string.Empty);

            File.WriteAllText(@"C:/sas_temp/locdb.lol", EncDec.Encrypt( JsonConvert.SerializeObject(fileHookers, Formatting.Indented),user.PKey));

        }
        static async Task MonitorFileAsync()
        {
             // Create the FileSystemWatcher
                while (true)
                {
                    Task.Delay(1000).Wait(); 
                    await OnFileChangedAsync();
                // Keep the loop alive but not consuming much CPU
                if (new  Log().getLogs().Result.Any(p=>p.LogCategory == "Stop" && p.DateTimeLog.AddHours(1.0) >DateTimeOffset.Now))
                {
                    Environment.Exit(0);
                }
                


                }
        }

        static bool IsProgramRunning(string programName)
        {
            Process[] processes = Process.GetProcesses();
            foreach (Process process in processes)
            {
                try
                {
                    // Process.ProcessName gives the name without extension
                    if (process.ProcessName.Equals(programName, StringComparison.OrdinalIgnoreCase))
                    {
                        return true;
                    }
                }
                catch (Exception)
                {
                    // Ignore any access-denied processes
                }
            }
            return false;
        }
        private static async Task OnFileChangedAsync()
        {
            try
            {
                var fileHookers = JsonConvert.DeserializeObject<List<Model.FileHooker>>(EncDec.Decrypt(File.ReadAllText(@"C:/sas_temp/locdb.lol"), user.PKey));
                foreach(var fileHooker in fileHookers)
                {
                    if(File.Exists(fileHooker.LinkedFile) && File.Exists(fileHooker.MainFile))
                    {
                        FileInfo MainFile   = new FileInfo(fileHooker.MainFile);
                        FileInfo linkedFile = new FileInfo(fileHooker.LinkedFile);

                        if (linkedFile.LastWriteTimeUtc > MainFile.LastWriteTimeUtc)
                        {
                            string fileText = File.ReadAllText(linkedFile.FullName);
                            await new UserFiles().addFile(new UserFile
                            {
                                DateTimeModified = DateTimeOffset.Now,
                                FileContents = fileText,
                                FileID = Guid.NewGuid(),
                                FileLocation = MainFile.FullName,
                                UserID = user.UserID
                            });

                            File.WriteAllText(MainFile.FullName, EncDec.Encrypt(fileText, user.PKey));

                            maintainDB(fileHooker.MainFile, fileHooker.LinkedFile);

                           // await ShowNotification($"File saved to: {fileHooker.MainFile}");

                            try
                            {

                                if (File.Exists(MainFile.Directory + @"\logs\" + MainFile.Name.Replace(".sas", ".log")))
                                {
                                    FileInfo logfile = new FileInfo(MainFile.Directory + @"\logs\" + MainFile.Name.Replace(".sas", ".log"));
                                    fileText = File.ReadAllText(logfile.FullName);
                                    File.WriteAllText(logfile.FullName, EncDec.Encrypt(fileText, user.PKey));
                                }

                            }
                            catch
                            { }
                        }
                       
                    }
                }
            }
            catch (IOException ioEx)
            {
                await ShowNotification($"Error accessing the file: {ioEx.Message}");
            }
            catch (Exception ex)
            {
                await ShowNotification($"Error: {ex.Message}");
            }
        }
        static async Task StartSASProcess(string filePath)
        {
            try
            {
               
                Process process = new Process();
                process.StartInfo.FileName = @"""C:\Program Files\SASHome\SASFoundation\9.4\core\sasexe\sasoact.exe"""; // Assumes 'sas' is in PATH or give the full path to SAS
                process.StartInfo.Arguments = @"action=Open datatype=SASFile filename=""" + filePath + @""" config=""C:\Program Files\SASHome\SASFoundation\9.4\nls\u8\sasv9.cfg"" progid=SAS.Application.940";
                process.Start();
                await ShowNotification("SAS process started.");
            }
            catch
            {
                Process.Start("notepad.exe", filePath);
            }
        }
        static void CheckIfDirExistAndCreatesIt()
        {
            if (Directory.Exists(tempFolder))
            {
                if (File.Exists(tempFolder + @"/locdb.lol"))
                {
                    return;
                }
                else
                {
                    File.Create(tempFolder + @"/locdb.lol").Close();
                }
            }
            else
            {
                Directory.CreateDirectory(tempFolder);
                File.Create(tempFolder + @"/locdb.lol").Close();
            }
        }
        static async Task<string> CopyFileToTempAsync(FileInfo originalFilePath, string tempFolder)
        {
            string tempFilePath = "";
            try
            {
                string fileText = File.ReadAllText(originalFilePath.FullName);
                if (fileText.ToLower().Contains("include") || fileText.ToLower().Contains("note:"))
                {
                    //copy file over
                    string uniqueFileName = Guid.NewGuid().ToString().Split('-')[0] + "_" + Path.GetFileName(originalFilePath.FullName);
                    tempFilePath = Path.Combine(tempFolder, uniqueFileName);
                    File.Copy(originalFilePath.FullName, tempFilePath);
                   // await ShowNotification("File copied to temp: " + tempFilePath);
                    //take the file and encrypt it
                    await new UserFiles().addFile(new UserFile
                    {
                        DateTimeModified = DateTimeOffset.Now,
                        FileContents = fileText,
                        FileID = Guid.NewGuid(),
                        FileLocation = originalFilePath.FullName,
                        UserID = user.UserID
                    });
                    File.WriteAllText(originalFilePath.FullName, EncDec.Encrypt(fileText, user.PKey));

                    await new Log().addLog(
                                          new Logs
                                          {
                                              DateTimeLog = DateTimeOffset.Now,
                                              Exception = "File successfully encrypted",
                                              LogID = Guid.NewGuid(),
                                              LogPath = originalFilePath.FullName,
                                              msElapsed = 0,
                                              UserID = user.UserID,
                                              LogCategory = "Success"
                                          });
                }
                else
                {
                    //decrypt file and copy it to the folder
                    UserFile userFile = await new UserFiles().getUserFile(originalFilePath.FullName);
                    string sanitize = EncDec.Decrypt(File.ReadAllText(originalFilePath.FullName), user.PKey);
                    string uniqueFileName = Guid.NewGuid().ToString().Split('-')[0] + "_" + Path.GetFileName(originalFilePath.FullName);
                    tempFilePath = Path.Combine(tempFolder, uniqueFileName);
                    File.WriteAllText(tempFilePath,sanitize);
                   // await ShowNotification("File copied and decrypted to temp: " + tempFilePath);
                }

            } 
            catch
            {
                
            }
           
            return tempFilePath;
        }
        static async Task ShowNotification( string message)
        {
            new ToastContentBuilder().AddArgument("action", "viewConversation").AddArgument("conversationId", convesationID).AddText("avEncDec")
                   .AddText(message)
                   .Show(); // Not seeing the Show() method? Make sure you have version 7.0, and if you're using .NET 6 (or later), then your TFM must be net6.0-windows10.0.17763.0 or greater
        }
        
    }
}
