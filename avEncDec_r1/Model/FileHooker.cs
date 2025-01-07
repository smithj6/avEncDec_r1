using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace avEncDec_r1.Model
{
    public class FileHooker
    {
        public Guid Guid { get; set; }
        public string MainFile {  get; set; }
        public string LinkedFile { get; set; }

        public DateTimeOffset DTOFile { get; set; }


    }
}
