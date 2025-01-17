namespace avEncDec_w1.UserControls
{
    partial class LogCheck
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
            this.btnDoLogs = new System.Windows.Forms.Button();
            this.lblPath = new System.Windows.Forms.Label();
            this.fbdPath = new System.Windows.Forms.FolderBrowserDialog();
            this.pnlHeader.SuspendLayout();
            this.pnlContent.SuspendLayout();
            this.SuspendLayout();
            // 
            // pnlHeader
            // 
            this.pnlHeader.Controls.Add(this.lblHeader);
            this.pnlHeader.Dock = System.Windows.Forms.DockStyle.Top;
            this.pnlHeader.Location = new System.Drawing.Point(0, 0);
            this.pnlHeader.Name = "pnlHeader";
            this.pnlHeader.Size = new System.Drawing.Size(792, 100);
            this.pnlHeader.TabIndex = 1;
            // 
            // lblHeader
            // 
            this.lblHeader.AutoSize = true;
            this.lblHeader.Font = new System.Drawing.Font("Microsoft Sans Serif", 21F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblHeader.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(158)))), ((int)(((byte)(161)))), ((int)(((byte)(176)))));
            this.lblHeader.Location = new System.Drawing.Point(298, 39);
            this.lblHeader.Name = "lblHeader";
            this.lblHeader.Size = new System.Drawing.Size(185, 32);
            this.lblHeader.TabIndex = 2;
            this.lblHeader.Text = "Log Checker";
            // 
            // pnlContent
            // 
            this.pnlContent.AutoSize = true;
            this.pnlContent.Controls.Add(this.btnDoLogs);
            this.pnlContent.Controls.Add(this.lblPath);
            this.pnlContent.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pnlContent.Location = new System.Drawing.Point(0, 100);
            this.pnlContent.Name = "pnlContent";
            this.pnlContent.Size = new System.Drawing.Size(792, 447);
            this.pnlContent.TabIndex = 3;
            // 
            // btnDoLogs
            // 
            this.btnDoLogs.FlatAppearance.BorderSize = 0;
            this.btnDoLogs.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnDoLogs.Font = new System.Drawing.Font("Nirmala UI", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnDoLogs.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(126)))), ((int)(((byte)(200)))));
            this.btnDoLogs.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.btnDoLogs.Location = new System.Drawing.Point(6, 49);
            this.btnDoLogs.Name = "btnDoLogs";
            this.btnDoLogs.Size = new System.Drawing.Size(783, 42);
            this.btnDoLogs.TabIndex = 10;
            this.btnDoLogs.Text = "Start";
            this.btnDoLogs.TextImageRelation = System.Windows.Forms.TextImageRelation.TextBeforeImage;
            this.btnDoLogs.UseVisualStyleBackColor = true;
            this.btnDoLogs.Click += new System.EventHandler(this.btnDoLogs_Click);
            // 
            // lblPath
            // 
            this.lblPath.AutoSize = true;
            this.lblPath.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblPath.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(158)))), ((int)(((byte)(161)))), ((int)(((byte)(176)))));
            this.lblPath.Location = new System.Drawing.Point(3, 3);
            this.lblPath.Name = "lblPath";
            this.lblPath.Size = new System.Drawing.Size(85, 16);
            this.lblPath.TabIndex = 3;
            this.lblPath.Text = "Path to folder";
            // 
            // LogCheck
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(46)))), ((int)(((byte)(51)))), ((int)(((byte)(73)))));
            this.Controls.Add(this.pnlContent);
            this.Controls.Add(this.pnlHeader);
            this.Name = "LogCheck";
            this.Size = new System.Drawing.Size(792, 547);
            this.pnlHeader.ResumeLayout(false);
            this.pnlHeader.PerformLayout();
            this.pnlContent.ResumeLayout(false);
            this.pnlContent.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Panel pnlHeader;
        private System.Windows.Forms.Label lblHeader;
        private System.Windows.Forms.Panel pnlContent;
        private System.Windows.Forms.Label lblPath;
        private System.Windows.Forms.Button btnDoLogs;
        private System.Windows.Forms.FolderBrowserDialog fbdPath;
    }
}
