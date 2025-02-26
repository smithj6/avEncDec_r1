namespace avEncDec_w1.UserControls
{
    partial class Manage
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
            this.pnlHeader = new System.Windows.Forms.Panel();
            this.lblHeader = new System.Windows.Forms.Label();
            this.pnlContent = new System.Windows.Forms.Panel();
            this.pnlButtons = new System.Windows.Forms.Panel();
            this.button1 = new System.Windows.Forms.Button();
            this.btnManageAdmins = new System.Windows.Forms.Button();
            this.btnTransferPrograms = new System.Windows.Forms.Button();
            this.pnlHeader.SuspendLayout();
            this.pnlButtons.SuspendLayout();
            this.SuspendLayout();
            // 
            // pnlHeader
            // 
            this.pnlHeader.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(46)))), ((int)(((byte)(51)))), ((int)(((byte)(73)))));
            this.pnlHeader.Controls.Add(this.lblHeader);
            this.pnlHeader.Dock = System.Windows.Forms.DockStyle.Top;
            this.pnlHeader.Location = new System.Drawing.Point(0, 0);
            this.pnlHeader.Name = "pnlHeader";
            this.pnlHeader.Size = new System.Drawing.Size(792, 41);
            this.pnlHeader.TabIndex = 1;
            // 
            // lblHeader
            // 
            this.lblHeader.AutoSize = true;
            this.lblHeader.Font = new System.Drawing.Font("Microsoft Sans Serif", 21F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblHeader.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(158)))), ((int)(((byte)(161)))), ((int)(((byte)(176)))));
            this.lblHeader.Location = new System.Drawing.Point(3, 0);
            this.lblHeader.Name = "lblHeader";
            this.lblHeader.Size = new System.Drawing.Size(123, 32);
            this.lblHeader.TabIndex = 2;
            this.lblHeader.Text = "Manage";
            // 
            // pnlContent
            // 
            this.pnlContent.AutoSize = true;
            this.pnlContent.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pnlContent.Location = new System.Drawing.Point(0, 83);
            this.pnlContent.Name = "pnlContent";
            this.pnlContent.Size = new System.Drawing.Size(792, 464);
            this.pnlContent.TabIndex = 2;
        
            // 
            // pnlButtons
            // 
            this.pnlButtons.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(192)))), ((int)(((byte)(255)))), ((int)(((byte)(192)))));
            this.pnlButtons.Controls.Add(this.button1);
            this.pnlButtons.Controls.Add(this.btnManageAdmins);
            this.pnlButtons.Controls.Add(this.btnTransferPrograms);
            this.pnlButtons.Dock = System.Windows.Forms.DockStyle.Top;
            this.pnlButtons.Location = new System.Drawing.Point(0, 41);
            this.pnlButtons.Name = "pnlButtons";
            this.pnlButtons.Size = new System.Drawing.Size(792, 42);
            this.pnlButtons.TabIndex = 3;
            // 
            // button1
            // 
            this.button1.Dock = System.Windows.Forms.DockStyle.Left;
            this.button1.FlatAppearance.BorderSize = 0;
            this.button1.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.button1.Font = new System.Drawing.Font("Nirmala UI", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.button1.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(126)))), ((int)(((byte)(200)))));
            this.button1.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.button1.Location = new System.Drawing.Point(372, 0);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(186, 42);
            this.button1.TabIndex = 9;
            this.button1.Text = "User Roles";
            this.button1.TextImageRelation = System.Windows.Forms.TextImageRelation.TextBeforeImage;
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.button1_Click);
            // 
            // btnManageAdmins
            // 
            this.btnManageAdmins.Dock = System.Windows.Forms.DockStyle.Left;
            this.btnManageAdmins.FlatAppearance.BorderSize = 0;
            this.btnManageAdmins.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnManageAdmins.Font = new System.Drawing.Font("Nirmala UI", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnManageAdmins.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(126)))), ((int)(((byte)(200)))));
            this.btnManageAdmins.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.btnManageAdmins.Location = new System.Drawing.Point(186, 0);
            this.btnManageAdmins.Name = "btnManageAdmins";
            this.btnManageAdmins.Size = new System.Drawing.Size(186, 42);
            this.btnManageAdmins.TabIndex = 8;
            this.btnManageAdmins.Text = "Mange Admins";
            this.btnManageAdmins.TextImageRelation = System.Windows.Forms.TextImageRelation.TextBeforeImage;
            this.btnManageAdmins.UseVisualStyleBackColor = true;
            this.btnManageAdmins.Click += new System.EventHandler(this.btnManageAdmins_Click);
            // 
            // btnTransferPrograms
            // 
            this.btnTransferPrograms.Dock = System.Windows.Forms.DockStyle.Left;
            this.btnTransferPrograms.FlatAppearance.BorderSize = 0;
            this.btnTransferPrograms.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnTransferPrograms.Font = new System.Drawing.Font("Nirmala UI", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnTransferPrograms.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(126)))), ((int)(((byte)(200)))));
            this.btnTransferPrograms.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.btnTransferPrograms.Location = new System.Drawing.Point(0, 0);
            this.btnTransferPrograms.Name = "btnTransferPrograms";
            this.btnTransferPrograms.Size = new System.Drawing.Size(186, 42);
            this.btnTransferPrograms.TabIndex = 7;
            this.btnTransferPrograms.Text = "Transfer Programs";
            this.btnTransferPrograms.TextImageRelation = System.Windows.Forms.TextImageRelation.TextBeforeImage;
            this.btnTransferPrograms.UseVisualStyleBackColor = true;
            this.btnTransferPrograms.Click += new System.EventHandler(this.btnTransferPrograms_Click);
            // 
            // Manage
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(46)))), ((int)(((byte)(51)))), ((int)(((byte)(73)))));
            this.Controls.Add(this.pnlContent);
            this.Controls.Add(this.pnlButtons);
            this.Controls.Add(this.pnlHeader);
            this.Name = "Manage";
            this.Size = new System.Drawing.Size(792, 547);
            this.pnlHeader.ResumeLayout(false);
            this.pnlHeader.PerformLayout();
            this.pnlButtons.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Panel pnlHeader;
        private System.Windows.Forms.Label lblHeader;
        private System.Windows.Forms.Panel pnlContent;
        private System.Windows.Forms.Panel pnlButtons;
        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.Button btnManageAdmins;
        private System.Windows.Forms.Button btnTransferPrograms;
    }
}
