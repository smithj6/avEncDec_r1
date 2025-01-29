namespace avEncDec_w1.UserControls
{
    partial class UserRolesC
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
            this.pnlContent = new System.Windows.Forms.Panel();
            this.lblHeader = new System.Windows.Forms.Label();
            this.pnlUsers = new System.Windows.Forms.Panel();
            this.pnlAdd = new System.Windows.Forms.Panel();
            this.btnAddPath = new System.Windows.Forms.Button();
            this.lblPath = new System.Windows.Forms.Label();
            this.pnlgvd = new System.Windows.Forms.Panel();
            this.fbd = new System.Windows.Forms.FolderBrowserDialog();
            this.pnlHeader.SuspendLayout();
            this.pnlAdd.SuspendLayout();
            this.SuspendLayout();
            // 
            // pnlHeader
            // 
            this.pnlHeader.Controls.Add(this.pnlContent);
            this.pnlHeader.Controls.Add(this.lblHeader);
            this.pnlHeader.Dock = System.Windows.Forms.DockStyle.Top;
            this.pnlHeader.Location = new System.Drawing.Point(0, 0);
            this.pnlHeader.Name = "pnlHeader";
            this.pnlHeader.Size = new System.Drawing.Size(765, 100);
            this.pnlHeader.TabIndex = 3;
            // 
            // pnlContent
            // 
            this.pnlContent.AutoSize = true;
            this.pnlContent.Location = new System.Drawing.Point(253, 100);
            this.pnlContent.Name = "pnlContent";
            this.pnlContent.Size = new System.Drawing.Size(539, 447);
            this.pnlContent.TabIndex = 5;
            // 
            // lblHeader
            // 
            this.lblHeader.AutoSize = true;
            this.lblHeader.Font = new System.Drawing.Font("Microsoft Sans Serif", 21F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblHeader.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(158)))), ((int)(((byte)(161)))), ((int)(((byte)(176)))));
            this.lblHeader.Location = new System.Drawing.Point(3, 0);
            this.lblHeader.Name = "lblHeader";
            this.lblHeader.Size = new System.Drawing.Size(148, 32);
            this.lblHeader.TabIndex = 2;
            this.lblHeader.Text = "User Role";
            // 
            // pnlUsers
            // 
            this.pnlUsers.Dock = System.Windows.Forms.DockStyle.Left;
            this.pnlUsers.Location = new System.Drawing.Point(0, 100);
            this.pnlUsers.Name = "pnlUsers";
            this.pnlUsers.Size = new System.Drawing.Size(187, 477);
            this.pnlUsers.TabIndex = 4;
            // 
            // pnlAdd
            // 
            this.pnlAdd.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(24)))), ((int)(((byte)(30)))), ((int)(((byte)(54)))));
            this.pnlAdd.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.pnlAdd.Controls.Add(this.btnAddPath);
            this.pnlAdd.Controls.Add(this.lblPath);
            this.pnlAdd.Dock = System.Windows.Forms.DockStyle.Top;
            this.pnlAdd.Location = new System.Drawing.Point(187, 100);
            this.pnlAdd.Name = "pnlAdd";
            this.pnlAdd.Size = new System.Drawing.Size(578, 153);
            this.pnlAdd.TabIndex = 5;
            // 
            // btnAddPath
            // 
            this.btnAddPath.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.btnAddPath.FlatAppearance.BorderSize = 0;
            this.btnAddPath.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnAddPath.Font = new System.Drawing.Font("Nirmala UI", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnAddPath.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(126)))), ((int)(((byte)(200)))));
            this.btnAddPath.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.btnAddPath.Location = new System.Drawing.Point(0, 109);
            this.btnAddPath.Name = "btnAddPath";
            this.btnAddPath.Size = new System.Drawing.Size(576, 42);
            this.btnAddPath.TabIndex = 8;
            this.btnAddPath.Text = "Add path";
            this.btnAddPath.TextImageRelation = System.Windows.Forms.TextImageRelation.TextBeforeImage;
            this.btnAddPath.UseVisualStyleBackColor = true;
            this.btnAddPath.Click += new System.EventHandler(this.btnAddPath_Click);
            // 
            // lblPath
            // 
            this.lblPath.AutoSize = true;
            this.lblPath.Dock = System.Windows.Forms.DockStyle.Top;
            this.lblPath.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblPath.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(158)))), ((int)(((byte)(161)))), ((int)(((byte)(176)))));
            this.lblPath.Location = new System.Drawing.Point(0, 0);
            this.lblPath.Name = "lblPath";
            this.lblPath.Size = new System.Drawing.Size(112, 15);
            this.lblPath.TabIndex = 3;
            this.lblPath.Text = "Add a path to folder";
            // 
            // pnlgvd
            // 
            this.pnlgvd.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.pnlgvd.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pnlgvd.Location = new System.Drawing.Point(187, 253);
            this.pnlgvd.Name = "pnlgvd";
            this.pnlgvd.Size = new System.Drawing.Size(578, 324);
            this.pnlgvd.TabIndex = 6;
            // 
            // UserRolesC
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(46)))), ((int)(((byte)(51)))), ((int)(((byte)(73)))));
            this.Controls.Add(this.pnlgvd);
            this.Controls.Add(this.pnlAdd);
            this.Controls.Add(this.pnlUsers);
            this.Controls.Add(this.pnlHeader);
            this.Name = "UserRolesC";
            this.Size = new System.Drawing.Size(765, 577);
            this.pnlHeader.ResumeLayout(false);
            this.pnlHeader.PerformLayout();
            this.pnlAdd.ResumeLayout(false);
            this.pnlAdd.PerformLayout();
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.Panel pnlHeader;
        private System.Windows.Forms.Label lblHeader;
        private System.Windows.Forms.Panel pnlContent;
        private System.Windows.Forms.Panel pnlUsers;
        private System.Windows.Forms.Panel pnlAdd;
        private System.Windows.Forms.Panel pnlgvd;
        private System.Windows.Forms.Label lblPath;
        private System.Windows.Forms.Button btnAddPath;
        private System.Windows.Forms.FolderBrowserDialog fbd;
    }
}
