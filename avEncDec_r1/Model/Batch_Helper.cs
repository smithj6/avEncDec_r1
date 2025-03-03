using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace avEncDec_r1.Model
{
    public class Batch_Helper
    {
        [Key]
        public Guid BatchItemGuid { get; set; }
        [Required]
        public int ProgramOrder { get; set; }
        [Required]
        public int BatchOrder { get; set; }
        [Required]
        public string DSNAME { get; set; }
        [Required]
        public string DSLABEL { get; set; }
    }
}
