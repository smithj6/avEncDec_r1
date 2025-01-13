using avEncDec_r1.Controllers;
using avEncDec_r1.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace avEncDec_w1
{
    static class GlobalVars
    {
        private static UserProfile _UserProfile = new UserProfile();

        public static UserProfile _User
        {
            get { return _UserProfile; }
            set { _UserProfile = value; }
        }
    }
}
