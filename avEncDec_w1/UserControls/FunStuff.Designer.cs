namespace avEncDec_w1.UserControls
{
    partial class FunStuff
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
            this.pnlButtons = new System.Windows.Forms.Panel();
            this.btnBatchRun = new System.Windows.Forms.Button();
            this.btnLogCheck = new System.Windows.Forms.Button();
            this.pnlContent = new System.Windows.Forms.Panel();
            this.btnTransfer = new System.Windows.Forms.Button();
            this.btnTransferSOP = new System.Windows.Forms.Button();
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
            this.pnlHeader.TabIndex = 2;
            // 
            // lblHeader
            // 
            this.lblHeader.AutoSize = true;
            this.lblHeader.Font = new System.Drawing.Font("Microsoft Sans Serif", 21F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.lblHeader.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(158)))), ((int)(((byte)(161)))), ((int)(((byte)(176)))));
            this.lblHeader.Location = new System.Drawing.Point(3, 0);
            this.lblHeader.Name = "lblHeader";
            this.lblHeader.Size = new System.Drawing.Size(138, 32);
            this.lblHeader.TabIndex = 2;
            this.lblHeader.Text = "Fun Stuff";
            // 
            // pnlButtons
            // 
            this.pnlButtons.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(192)))), ((int)(((byte)(255)))), ((int)(((byte)(192)))));
            this.pnlButtons.Controls.Add(this.btnTransferSOP);
            this.pnlButtons.Controls.Add(this.btnTransfer);
            this.pnlButtons.Controls.Add(this.btnBatchRun);
            this.pnlButtons.Controls.Add(this.btnLogCheck);
            this.pnlButtons.Dock = System.Windows.Forms.DockStyle.Top;
            this.pnlButtons.Location = new System.Drawing.Point(0, 41);
            this.pnlButtons.Name = "pnlButtons";
            this.pnlButtons.Size = new System.Drawing.Size(792, 42);
            this.pnlButtons.TabIndex = 4;
            // 
            // btnBatchRun
            // 
            this.btnBatchRun.Dock = System.Windows.Forms.DockStyle.Left;
            this.btnBatchRun.FlatAppearance.BorderSize = 0;
            this.btnBatchRun.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnBatchRun.Font = new System.Drawing.Font("Nirmala UI", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnBatchRun.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(126)))), ((int)(((byte)(200)))));
            this.btnBatchRun.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.btnBatchRun.Location = new System.Drawing.Point(186, 0);
            this.btnBatchRun.Name = "btnBatchRun";
            this.btnBatchRun.Size = new System.Drawing.Size(186, 42);
            this.btnBatchRun.TabIndex = 8;
            this.btnBatchRun.Text = "Batch Run";
            this.btnBatchRun.TextImageRelation = System.Windows.Forms.TextImageRelation.TextBeforeImage;
            this.btnBatchRun.UseVisualStyleBackColor = true;
            this.btnBatchRun.Click += new System.EventHandler(this.btnBatchRun_Click);
            // 
            // btnLogCheck
            // 
            this.btnLogCheck.Dock = System.Windows.Forms.DockStyle.Left;
            this.btnLogCheck.FlatAppearance.BorderSize = 0;
            this.btnLogCheck.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnLogCheck.Font = new System.Drawing.Font("Nirmala UI", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnLogCheck.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(126)))), ((int)(((byte)(200)))));
            this.btnLogCheck.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.btnLogCheck.Location = new System.Drawing.Point(0, 0);
            this.btnLogCheck.Name = "btnLogCheck";
            this.btnLogCheck.Size = new System.Drawing.Size(186, 42);
            this.btnLogCheck.TabIndex = 7;
            this.btnLogCheck.Text = "Log Check";
            this.btnLogCheck.TextImageRelation = System.Windows.Forms.TextImageRelation.TextBeforeImage;
            this.btnLogCheck.UseVisualStyleBackColor = true;
            this.btnLogCheck.Click += new System.EventHandler(this.btnLogCheck_Click);
            // 
            // pnlContent
            // 
            this.pnlContent.AutoSize = true;
            this.pnlContent.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pnlContent.Location = new System.Drawing.Point(0, 83);
            this.pnlContent.Name = "pnlContent";
            this.pnlContent.Size = new System.Drawing.Size(792, 381);
            this.pnlContent.TabIndex = 5;
            // 
            // btnTransfer
            // 
            this.btnTransfer.Dock = System.Windows.Forms.DockStyle.Left;
            this.btnTransfer.FlatAppearance.BorderSize = 0;
            this.btnTransfer.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnTransfer.Font = new System.Drawing.Font("Nirmala UI", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnTransfer.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(126)))), ((int)(((byte)(200)))));
            this.btnTransfer.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.btnTransfer.Location = new System.Drawing.Point(372, 0);
            this.btnTransfer.Name = "btnTransfer";
            this.btnTransfer.Size = new System.Drawing.Size(186, 42);
            this.btnTransfer.TabIndex = 9;
            this.btnTransfer.Text = "Transfer M5";
            this.btnTransfer.TextImageRelation = System.Windows.Forms.TextImageRelation.TextBeforeImage;
            this.btnTransfer.UseVisualStyleBackColor = true;
            this.btnTransfer.Click += new System.EventHandler(this.btnTransfer_Click);
            // 
            // btnTransferSOP
            // 
            this.btnTransferSOP.Dock = System.Windows.Forms.DockStyle.Left;
            this.btnTransferSOP.FlatAppearance.BorderSize = 0;
            this.btnTransferSOP.FlatStyle = System.Windows.Forms.FlatStyle.Popup;
            this.btnTransferSOP.Font = new System.Drawing.Font("Nirmala UI", 9.75F, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnTransferSOP.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(126)))), ((int)(((byte)(200)))));
            this.btnTransferSOP.ImageAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.btnTransferSOP.Location = new System.Drawing.Point(558, 0);
            this.btnTransferSOP.Name = "btnTransferSOP";
            this.btnTransferSOP.Size = new System.Drawing.Size(186, 42);
            this.btnTransferSOP.TabIndex = 10;
            this.btnTransferSOP.Text = "Transfer SOP";
            this.btnTransferSOP.TextImageRelation = System.Windows.Forms.TextImageRelation.TextAboveImage;
            this.btnTransferSOP.UseVisualStyleBackColor = true;
            this.btnTransferSOP.Click += new System.EventHandler(this.btnTransferSOP_Click);
            // 
            // FunStuff
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(46)))), ((int)(((byte)(51)))), ((int)(((byte)(73)))));
            this.Controls.Add(this.pnlContent);
            this.Controls.Add(this.pnlButtons);
            this.Controls.Add(this.pnlHeader);
            this.Name = "FunStuff";
            this.Size = new System.Drawing.Size(792, 464);
            this.pnlHeader.ResumeLayout(false);
            this.pnlHeader.PerformLayout();
            this.pnlButtons.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Panel pnlHeader;
        private System.Windows.Forms.Label lblHeader;
        private System.Windows.Forms.Panel pnlButtons;
        private System.Windows.Forms.Button btnBatchRun;
        private System.Windows.Forms.Button btnLogCheck;
        private System.Windows.Forms.Panel pnlContent;
        private System.Windows.Forms.Button btnTransfer;
        private System.Windows.Forms.Button btnTransferSOP;
    }
}
