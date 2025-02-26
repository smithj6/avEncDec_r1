namespace avEncDec_w1.UserControls.ManageUC
{
    partial class TransferPrograms
    {
        /// <summary> 
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary> 
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Component Designer generated code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.pnlFile = new System.Windows.Forms.Panel();
            this.lblFilesSelected = new System.Windows.Forms.Label();
            this.btnSelectFiles = new System.Windows.Forms.Button();
            this.pnlUsers = new System.Windows.Forms.Panel();
            this.lblHelper = new System.Windows.Forms.Label();
            this.PnlPeople = new System.Windows.Forms.Panel();
            this.pnlFile.SuspendLayout();
            this.pnlUsers.SuspendLayout();
            this.SuspendLayout();
            // 
            // pnlFile
            // 
            this.pnlFile.Controls.Add(this.lblFilesSelected);
            this.pnlFile.Controls.Add(this.btnSelectFiles);
            this.pnlFile.Dock = System.Windows.Forms.DockStyle.Top;
            this.pnlFile.Location = new System.Drawing.Point(0, 0);
            this.pnlFile.Name = "pnlFile";
            this.pnlFile.Size = new System.Drawing.Size(765, 78);
            this.pnlFile.TabIndex = 0;
            // 
            // lblFilesSelected
            // 
            this.lblFilesSelected.AutoSize = true;
            this.lblFilesSelected.Dock = System.Windows.Forms.DockStyle.Top;
            this.lblFilesSelected.ForeColor = System.Drawing.SystemColors.ButtonFace;
            this.lblFilesSelected.Location = new System.Drawing.Point(0, 42);
            this.lblFilesSelected.Name = "lblFilesSelected";
            this.lblFilesSelected.Size = new System.Drawing.Size(0, 13);
            this.lblFilesSelected.TabIndex = 4;
            // 
            // btnSelectFiles
            // 
            this.btnSelectFiles.Dock = System.Windows.Forms.DockStyle.Top;
            this.btnSelectFiles.FlatAppearance.BorderSize = 0;
            this.btnSelectFiles.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnSelectFiles.Font = new System.Drawing.Font("Nirmala UI", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnSelectFiles.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(126)))), ((int)(((byte)(200)))));
            this.btnSelectFiles.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.btnSelectFiles.Location = new System.Drawing.Point(0, 0);
            this.btnSelectFiles.Name = "btnSelectFiles";
            this.btnSelectFiles.Size = new System.Drawing.Size(765, 42);
            this.btnSelectFiles.TabIndex = 3;
            this.btnSelectFiles.Text = "Select Files";
            this.btnSelectFiles.TextImageRelation = System.Windows.Forms.TextImageRelation.TextBeforeImage;
            this.btnSelectFiles.UseVisualStyleBackColor = true;
            this.btnSelectFiles.Click += new System.EventHandler(this.btnSelectFiles_Click);
            // 
            // pnlUsers
            // 
            this.pnlUsers.Controls.Add(this.lblHelper);
            this.pnlUsers.Dock = System.Windows.Forms.DockStyle.Top;
            this.pnlUsers.Location = new System.Drawing.Point(0, 78);
            this.pnlUsers.Name = "pnlUsers";
            this.pnlUsers.Size = new System.Drawing.Size(765, 32);
            this.pnlUsers.TabIndex = 1;
            // 
            // lblHelper
            // 
            this.lblHelper.AutoSize = true;
            this.lblHelper.Dock = System.Windows.Forms.DockStyle.Top;
            this.lblHelper.Font = new System.Drawing.Font("Nirmala UI", 12F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblHelper.ForeColor = System.Drawing.SystemColors.ButtonFace;
            this.lblHelper.Location = new System.Drawing.Point(0, 0);
            this.lblHelper.Name = "lblHelper";
            this.lblHelper.Size = new System.Drawing.Size(417, 21);
            this.lblHelper.TabIndex = 5;
            this.lblHelper.Text = "Select a user to who the programs will be migrated to";
            this.lblHelper.Visible = false;
            // 
            // PnlPeople
            // 
            this.PnlPeople.Dock = System.Windows.Forms.DockStyle.Top;
            this.PnlPeople.Location = new System.Drawing.Point(0, 110);
            this.PnlPeople.Name = "PnlPeople";
            this.PnlPeople.Size = new System.Drawing.Size(765, 464);
            this.PnlPeople.TabIndex = 2;
            // 
            // TransferPrograms
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(46)))), ((int)(((byte)(51)))), ((int)(((byte)(73)))));
            this.Controls.Add(this.PnlPeople);
            this.Controls.Add(this.pnlUsers);
            this.Controls.Add(this.pnlFile);
            this.Name = "TransferPrograms";
            this.Size = new System.Drawing.Size(765, 577);
            this.pnlFile.ResumeLayout(false);
            this.pnlFile.PerformLayout();
            this.pnlUsers.ResumeLayout(false);
            this.pnlUsers.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel pnlFile;
        private System.Windows.Forms.Label lblFilesSelected;
        private System.Windows.Forms.Button btnSelectFiles;
        private System.Windows.Forms.Panel pnlUsers;
        private System.Windows.Forms.Label lblHelper;
        private System.Windows.Forms.Panel PnlPeople;
    }
}
