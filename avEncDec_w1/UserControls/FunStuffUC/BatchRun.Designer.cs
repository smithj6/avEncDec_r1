namespace avEncDec_w1.UserControls.FunStuffUC
{
    partial class BatchRun
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
            this.pnlContent = new System.Windows.Forms.Panel();
            this.btnDoBatch = new System.Windows.Forms.Button();
            this.lblPath = new System.Windows.Forms.Label();
            this.pnlHeader = new System.Windows.Forms.Panel();
            this.lblHeader = new System.Windows.Forms.Label();
            this.pnlContent.SuspendLayout();
            this.pnlHeader.SuspendLayout();
            this.SuspendLayout();
            // 
            // pnlContent
            // 
            this.pnlContent.AutoSize = true;
            this.pnlContent.Controls.Add(this.btnDoBatch);
            this.pnlContent.Controls.Add(this.lblPath);
            this.pnlContent.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pnlContent.Location = new System.Drawing.Point(0, 40);
            this.pnlContent.Name = "pnlContent";
            this.pnlContent.Size = new System.Drawing.Size(792, 507);
            this.pnlContent.TabIndex = 5;
            // 
            // btnDoBatch
            // 
            this.btnDoBatch.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.btnDoBatch.FlatAppearance.BorderSize = 0;
            this.btnDoBatch.FlatStyle = System.Windows.Forms.FlatStyle.Flat;
            this.btnDoBatch.Font = new System.Drawing.Font("Nirmala UI", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnDoBatch.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(126)))), ((int)(((byte)(200)))));
            this.btnDoBatch.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.btnDoBatch.Location = new System.Drawing.Point(0, 465);
            this.btnDoBatch.Name = "btnDoBatch";
            this.btnDoBatch.Size = new System.Drawing.Size(792, 42);
            this.btnDoBatch.TabIndex = 10;
            this.btnDoBatch.Text = "Start";
            this.btnDoBatch.TextImageRelation = System.Windows.Forms.TextImageRelation.TextBeforeImage;
            this.btnDoBatch.UseVisualStyleBackColor = true;
            this.btnDoBatch.Click += new System.EventHandler(this.btnDoBatch_Click);
            // 
            // lblPath
            // 
            this.lblPath.AutoSize = true;
            this.lblPath.Dock = System.Windows.Forms.DockStyle.Top;
            this.lblPath.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblPath.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(158)))), ((int)(((byte)(161)))), ((int)(((byte)(176)))));
            this.lblPath.Location = new System.Drawing.Point(0, 0);
            this.lblPath.Name = "lblPath";
            this.lblPath.Size = new System.Drawing.Size(85, 16);
            this.lblPath.TabIndex = 3;
            this.lblPath.Text = "Path to folder";
            // 
            // pnlHeader
            // 
            this.pnlHeader.Controls.Add(this.lblHeader);
            this.pnlHeader.Dock = System.Windows.Forms.DockStyle.Top;
            this.pnlHeader.Location = new System.Drawing.Point(0, 0);
            this.pnlHeader.Name = "pnlHeader";
            this.pnlHeader.Size = new System.Drawing.Size(792, 40);
            this.pnlHeader.TabIndex = 4;
            // 
            // lblHeader
            // 
            this.lblHeader.AutoSize = true;
            this.lblHeader.Font = new System.Drawing.Font("Microsoft Sans Serif", 21F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblHeader.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(158)))), ((int)(((byte)(161)))), ((int)(((byte)(176)))));
            this.lblHeader.Location = new System.Drawing.Point(0, 0);
            this.lblHeader.Name = "lblHeader";
            this.lblHeader.Size = new System.Drawing.Size(155, 32);
            this.lblHeader.TabIndex = 2;
            this.lblHeader.Text = "Batch Run";
            // 
            // BatchRun
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(46)))), ((int)(((byte)(51)))), ((int)(((byte)(73)))));
            this.Controls.Add(this.pnlContent);
            this.Controls.Add(this.pnlHeader);
            this.Name = "BatchRun";
            this.Size = new System.Drawing.Size(792, 547);
            this.pnlContent.ResumeLayout(false);
            this.pnlContent.PerformLayout();
            this.pnlHeader.ResumeLayout(false);
            this.pnlHeader.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Panel pnlContent;
        private System.Windows.Forms.Button btnDoBatch;
        private System.Windows.Forms.Label lblPath;
        private System.Windows.Forms.Panel pnlHeader;
        private System.Windows.Forms.Label lblHeader;
    }
}
