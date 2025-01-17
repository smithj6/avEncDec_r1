namespace avEncDec_w1.UserControls
{
    partial class UserRoles
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
            this.label1 = new System.Windows.Forms.Label();
            this.textBox1 = new System.Windows.Forms.TextBox();
            this.pnlgvd = new System.Windows.Forms.Panel();
            this.gdvUserRoles = new System.Windows.Forms.DataGridView();
            this.pnlHeader.SuspendLayout();
            this.pnlAdd.SuspendLayout();
            this.pnlgvd.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.gdvUserRoles)).BeginInit();
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
            this.lblHeader.Location = new System.Drawing.Point(298, 39);
            this.lblHeader.Name = "lblHeader";
            this.lblHeader.Size = new System.Drawing.Size(148, 32);
            this.lblHeader.TabIndex = 2;
            this.lblHeader.Text = "User Role";
            // 
            // pnlUsers
            // 
            this.pnlUsers.Location = new System.Drawing.Point(3, 106);
            this.pnlUsers.Name = "pnlUsers";
            this.pnlUsers.Size = new System.Drawing.Size(187, 468);
            this.pnlUsers.TabIndex = 4;
            // 
            // pnlAdd
            // 
            this.pnlAdd.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(24)))), ((int)(((byte)(30)))), ((int)(((byte)(54)))));
            this.pnlAdd.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.pnlAdd.Controls.Add(this.btnAddPath);
            this.pnlAdd.Controls.Add(this.label1);
            this.pnlAdd.Controls.Add(this.textBox1);
            this.pnlAdd.Location = new System.Drawing.Point(197, 107);
            this.pnlAdd.Name = "pnlAdd";
            this.pnlAdd.Size = new System.Drawing.Size(564, 153);
            this.pnlAdd.TabIndex = 5;
            // 
            // btnAddPath
            // 
            this.btnAddPath.FlatAppearance.BorderSize = 0;
            this.btnAddPath.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnAddPath.Font = new System.Drawing.Font("Nirmala UI", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnAddPath.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(126)))), ((int)(((byte)(200)))));
            this.btnAddPath.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.btnAddPath.Location = new System.Drawing.Point(0, 54);
            this.btnAddPath.Name = "btnAddPath";
            this.btnAddPath.Size = new System.Drawing.Size(115, 42);
            this.btnAddPath.TabIndex = 8;
            this.btnAddPath.Text = "Add path";
            this.btnAddPath.TextImageRelation = System.Windows.Forms.TextImageRelation.TextBeforeImage;
            this.btnAddPath.UseVisualStyleBackColor = true;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(158)))), ((int)(((byte)(161)))), ((int)(((byte)(176)))));
            this.label1.Location = new System.Drawing.Point(3, 7);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(112, 15);
            this.label1.TabIndex = 3;
            this.label1.Text = "Add a path to folder";
            // 
            // textBox1
            // 
            this.textBox1.Location = new System.Drawing.Point(3, 25);
            this.textBox1.Name = "textBox1";
            this.textBox1.Size = new System.Drawing.Size(556, 20);
            this.textBox1.TabIndex = 0;
            // 
            // pnlgvd
            // 
            this.pnlgvd.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle;
            this.pnlgvd.Controls.Add(this.gdvUserRoles);
            this.pnlgvd.Location = new System.Drawing.Point(197, 265);
            this.pnlgvd.Name = "pnlgvd";
            this.pnlgvd.Size = new System.Drawing.Size(565, 309);
            this.pnlgvd.TabIndex = 6;
            // 
            // gdvUserRoles
            // 
            this.gdvUserRoles.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.gdvUserRoles.Dock = System.Windows.Forms.DockStyle.Fill;
            this.gdvUserRoles.Location = new System.Drawing.Point(0, 0);
            this.gdvUserRoles.Name = "gdvUserRoles";
            this.gdvUserRoles.Size = new System.Drawing.Size(563, 307);
            this.gdvUserRoles.TabIndex = 0;
            // 
            // UserRoles
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(46)))), ((int)(((byte)(51)))), ((int)(((byte)(73)))));
            this.Controls.Add(this.pnlgvd);
            this.Controls.Add(this.pnlAdd);
            this.Controls.Add(this.pnlUsers);
            this.Controls.Add(this.pnlHeader);
            this.Name = "UserRoles";
            this.Size = new System.Drawing.Size(765, 577);
            this.pnlHeader.ResumeLayout(false);
            this.pnlHeader.PerformLayout();
            this.pnlAdd.ResumeLayout(false);
            this.pnlAdd.PerformLayout();
            this.pnlgvd.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)(this.gdvUserRoles)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.Panel pnlHeader;
        private System.Windows.Forms.Label lblHeader;
        private System.Windows.Forms.Panel pnlContent;
        private System.Windows.Forms.Panel pnlUsers;
        private System.Windows.Forms.Panel pnlAdd;
        private System.Windows.Forms.Panel pnlgvd;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox textBox1;
        private System.Windows.Forms.DataGridView gdvUserRoles;
        private System.Windows.Forms.Button btnAddPath;
    }
}
