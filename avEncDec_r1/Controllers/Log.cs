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
    public class Log
    {
        public async Task addLog(Logs logs)
        {
            using (var ctx = new avEncDecContext())
            {
                ctx.Logs.Add(logs);
                await ctx.SaveChangesAsync();
            }
        }

        public async Task<List<Logs>> getLogs()
        {
            using (var ctx = new avEncDecContext())
            {
                return await ctx.Logs.OrderByDescending(p => p.DateTimeLog).ToListAsync();
            }
        }
    }
}
