using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace avEncDec_r1.Model
{
    [Table("UserFile")]
    public class UserFile
    {
        [Key]
        public Guid FileID { get; set; }
        [Required]
        public string FileLocation { get; set; }
        [Required]
        public string FileContents { get; set; }
        [Required]
        public DateTimeOffset DateTimeModified { get; set; }
        [Required]
        public Guid UserID { get; set; }

    }
}
