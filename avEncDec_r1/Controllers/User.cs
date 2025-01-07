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
    public class User
    {
        public void addUser(UserProfile user)
        {

        }
        public async Task<UserProfile> checkUser()
        {
            UserProfile _user = new UserProfile();
            using (var ctx = new avEncDecContext())
            {
                if (!ctx.Users.Any(p => p.UserName == Environment.UserName))
                {
                    _user = new UserProfile
                    {
                        isActive = true,
                        UserName = Environment.UserName,
                        PKey = KeyGenerator.GetUniqueKey(10),
                        UserCreated = DateTimeOffset.Now,
                        UserID = Guid.NewGuid()
                    };
                    ctx.Users.Add(_user);

                    await ctx.SaveChangesAsync();
                }
                else
                {
                    _user = await ctx.Users.FirstOrDefaultAsync(p => p.UserName == Environment.UserName && p.isActive);
                }
            }
            return await Task.FromResult(_user);
        }



        public async Task<UserProfile> getSubUser(Guid _userId)
        {
            using (var ctx = new avEncDecContext())
            {
                return await ctx.Users.FirstOrDefaultAsync(p => p.UserID == _userId);
            }

        }

        public async Task<UserProfile> getSubUser(string _username)
        {
            using (var ctx = new avEncDecContext())
            {
                return await ctx.Users.FirstOrDefaultAsync(p => p.UserName.ToLower() == _username.ToLower());
            }
        }

        public async Task<UserProfile> setUserAdmin(string _username, UserProfile _userAdmin, bool _b)
        {
            using (var ctx = new avEncDecContext())
            {
                var i = await ctx.Users.FirstOrDefaultAsync(p => p.UserName.ToLower() == _username.ToLower());
                if (i != null)
                {
                    i.IsAdmin = _b;
                    i.UserIDAdmin = _userAdmin.UserID;
                    i.AdminDateTimeGranted = DateTimeOffset.Now;

                    await ctx.SaveChangesAsync();

                    return i;
                }
                return null;

            }
        }

        public async Task<List<UserProfile>> getUsers()
        {
            using (var ctx = new avEncDecContext())
            {
                return await ctx.Users.OrderBy(p => p.UserCreated).ToListAsync();
            }
        }
    }
}
