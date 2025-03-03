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
    public class Batch_Helpers
    {
        public async Task addBatch_Helper(Batch_Helper batch_Helper)
        {
            using (var ctx = new avEncDecContext())
            {
                ctx.Batch_Helper.Add(batch_Helper);
                await ctx.SaveChangesAsync();
            }
        }

        public async Task<List<Batch_Helper>> getbatch_Helpers()
        {
            using (var ctx = new avEncDecContext())
            {
                return await ctx.Batch_Helper.OrderByDescending(p => p.BatchOrder).ToListAsync();
            }
        }
    }
}
