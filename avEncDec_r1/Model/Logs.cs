using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace avEncDec_r1.Model
{
    [Table("Logs")]
    public class Logs
    {
        [Key]
        public Guid LogID { get; set; }
        [Required]
        public DateTimeOffset DateTimeLog { get; set; }

        public string LogPath { get; set; }
        [Required]
        public long msElapsed { get; set; }
        public string Exception { get; set; }
        [Required]
        public Guid UserID { get; set; }
        [Required]
        public string LogCategory { get; set; }

    }
}
