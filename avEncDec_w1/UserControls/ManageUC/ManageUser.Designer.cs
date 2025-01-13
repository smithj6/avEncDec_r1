namespace avEncDec_w1.UserControls.ManageUC
{
    partial class ManageUser
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
            this.panel1 = new System.Windows.Forms.Panel();
            this.lblUserName = new System.Windows.Forms.Label();
            this.panel2 = new System.Windows.Forms.Panel();
            this.isActive = new System.Windows.Forms.CheckBox();
            this.isAdmin = new System.Windows.Forms.CheckBox();
            this.panel3 = new System.Windows.Forms.Panel();
            this.panel4 = new System.Windows.Forms.Panel();
            this.btnMangeUser = new System.Windows.Forms.Button();
            this.panel1.SuspendLayout();
            this.panel2.SuspendLayout();
            this.panel3.SuspendLayout();
            this.panel4.SuspendLayout();
            this.SuspendLayout();
            // 
            // panel1
            // 
            this.panel1.Controls.Add(this.lblUserName);
            this.panel1.Dock = System.Windows.Forms.DockStyle.Left;
            this.panel1.Location = new System.Drawing.Point(0, 0);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(273, 50);
            this.panel1.TabIndex = 0;
            // 
            // lblUserName
            // 
            this.lblUserName.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.lblUserName.AutoSize = true;
            this.lblUserName.Location = new System.Drawing.Point(54, 20);
            this.lblUserName.Name = "lblUserName";
            this.lblUserName.Size = new System.Drawing.Size(67, 13);
            this.lblUserName.TabIndex = 0;
            this.lblUserName.Text = "lblUserName";
            // 
            // panel2
            // 
            this.panel2.Controls.Add(this.isActive);
            this.panel2.Dock = System.Windows.Forms.DockStyle.Left;
            this.panel2.Location = new System.Drawing.Point(273, 0);
            this.panel2.Name = "panel2";
            this.panel2.Size = new System.Drawing.Size(174, 50);
            this.panel2.TabIndex = 1;
            // 
            // isActive
            // 
            this.isActive.AutoSize = true;
            this.isActive.Location = new System.Drawing.Point(63, 19);
            this.isActive.Name = "isActive";
            this.isActive.Size = new System.Drawing.Size(56, 17);
            this.isActive.TabIndex = 1;
            this.isActive.Text = "Active";
            this.isActive.UseVisualStyleBackColor = true;
            this.isActive.CheckedChanged += new System.EventHandler(this.isActive_CheckedChanged);
            // 
            // isAdmin
            // 
            this.isAdmin.AutoSize = true;
            this.isAdmin.Location = new System.Drawing.Point(63, 19);
            this.isAdmin.Name = "isAdmin";
            this.isAdmin.Size = new System.Drawing.Size(55, 17);
            this.isAdmin.TabIndex = 1;
            this.isAdmin.Text = "Admin";
            this.isAdmin.UseVisualStyleBackColor = true;
            this.isAdmin.CheckedChanged += new System.EventHandler(this.isAdmin_CheckedChanged);
            // 
            // panel3
            // 
            this.panel3.Controls.Add(this.isAdmin);
            this.panel3.Dock = System.Windows.Forms.DockStyle.Left;
            this.panel3.Location = new System.Drawing.Point(447, 0);
            this.panel3.Name = "panel3";
            this.panel3.Size = new System.Drawing.Size(172, 50);
            this.panel3.TabIndex = 2;
            // 
            // panel4
            // 
            this.panel4.Controls.Add(this.btnMangeUser);
            this.panel4.Dock = System.Windows.Forms.DockStyle.Left;
            this.panel4.Location = new System.Drawing.Point(619, 0);
            this.panel4.Name = "panel4";
            this.panel4.Size = new System.Drawing.Size(174, 50);
            this.panel4.TabIndex = 3;
            // 
            // btnMangeUser
            // 
            this.btnMangeUser.Dock = System.Windows.Forms.DockStyle.Top;
            this.btnMangeUser.FlatAppearance.BorderSize = 0;
            this.btnMangeUser.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnMangeUser.Font = new System.Drawing.Font("Nirmala UI", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnMangeUser.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(126)))), ((int)(((byte)(200)))));
            this.btnMangeUser.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.btnMangeUser.Location = new System.Drawing.Point(0, 0);
            this.btnMangeUser.Name = "btnMangeUser";
            this.btnMangeUser.Size = new System.Drawing.Size(174, 50);
            this.btnMangeUser.TabIndex = 4;
            this.btnMangeUser.Text = "Manage";
            this.btnMangeUser.TextImageRelation = System.Windows.Forms.TextImageRelation.TextBeforeImage;
            this.btnMangeUser.UseVisualStyleBackColor = true;
            this.btnMangeUser.Click += new System.EventHandler(this.btnMangeUser_Click);
            // 
            // ManageUser
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.panel4);
            this.Controls.Add(this.panel3);
            this.Controls.Add(this.panel2);
            this.Controls.Add(this.panel1);
            this.Name = "ManageUser";
            this.Size = new System.Drawing.Size(792, 50);
            this.Load += new System.EventHandler(this.ManageUser_Load);
            this.panel1.ResumeLayout(false);
            this.panel1.PerformLayout();
            this.panel2.ResumeLayout(false);
            this.panel2.PerformLayout();
            this.panel3.ResumeLayout(false);
            this.panel3.PerformLayout();
            this.panel4.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Label lblUserName;
        private System.Windows.Forms.Panel panel2;
        private System.Windows.Forms.CheckBox isActive;
        private System.Windows.Forms.CheckBox isAdmin;
        private System.Windows.Forms.Panel panel3;
        private System.Windows.Forms.Panel panel4;
        private System.Windows.Forms.Button btnMangeUser;
    }
}
