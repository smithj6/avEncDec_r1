﻿using avEncDec_r1.Model;
using System.Data.Entity;

namespace avEncDec_r1.Context
{
    internal class avEncDecContext : DbContext
    {
        public avEncDecContext() : base("Data Source=avance.database.windows.net;Initial Catalog=code-encryption-dev;Persist Security Info=True;User ID=encryption-app;Password=breccia-SOLO-forfeit511;Encrypt=True")
        {
            Database.SetInitializer<avEncDecContext>(new CreateDatabaseIfNotExists<avEncDecContext>());
        }

        public DbSet<UserProfile> Users { get; set; }
        public DbSet<UserRole> Roles { get; set; }
        public DbSet<UserFile> Files { get; set; }
        public DbSet<Logs> Logs { get; set; }
    }
}
