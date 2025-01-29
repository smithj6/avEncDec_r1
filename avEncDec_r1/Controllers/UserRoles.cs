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
    public class UserRoles
    {
        public async Task<List<UserRole>> getAllUserRoles(Guid UserID)
        {
            using (var ctx = new avEncDecContext())
            {
                return await ctx.UserRoles.Where(p => p.UserID == UserID).ToListAsync();
            }
        }
        public async Task addUserRole(UserRole _userRole)
        {
            using (var ctx = new avEncDecContext())
            {
                ctx.UserRoles.Add( _userRole );
                await ctx.SaveChangesAsync();
            }
        }

        public async Task RemoveUserRole(UserRole _userRole)
        {
            using (var ctx = new avEncDecContext())
            {
                UserRole _loc = ctx.UserRoles.Where(p => p.RoleGUID == _userRole.RoleGUID).FirstOrDefault();
                if (_loc !=  null)
                {
                    _loc.isActive = false;
                    await ctx.SaveChangesAsync();
                }
              
                
            }
        }
    }
}
