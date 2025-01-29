using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace avEncDec_r1.Model
{
    [Table("UserRole")]
    public class UserRole
    {
        [Key]
        public Guid RoleGUID { get; set; }
        [Required]
        public string StudyPath { get; set; }
        [Required]
        public string RoleOnStudy { get; set; }
        [Required]
        public bool isActive { get; set; }
        [Required]
        public DateTimeOffset RoleCreatedDateTime { get; set; }
        [Required]
        public Guid UserID { get; set; }
        [Required]
        public Guid CreatedByUserID { get; set; }

    }
}
