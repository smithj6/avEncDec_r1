using avEncDec_r1.Context;
using avEncDec_r1.Model;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace avEncDec_r1.Controllers
{
    public class UserFiles
    {
        public async Task addFile(UserFile userFile)
        {
            using (var ctx = new avEncDecContext())
            {
                ctx.Files.Add(userFile);
                await ctx.SaveChangesAsync();
            }
        }
        public async Task<Model.UserFile> getUserFile(string filelocation)
        {
            using (var ctx = new avEncDecContext())
            {
                return await ctx.Files.FirstOrDefaultAsync(p => p.FileLocation == filelocation);
            }

        }

        public async Task<List<UserFile>> getAllUserFiles()
        {
            using (var ctx = new avEncDecContext())
            {
                return await ctx.Files.OrderBy(p => p.DateTimeModified).ToListAsync();
            }
        }

    }
}
