using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace avEncDec_r1.Model
{
    [Table("UserProfile")]
    public class UserProfile
    {
        [Key]
        public Guid UserID { get; set; }
        [Required]
        public string UserName { get; set; }
        [Required]
        public string PKey { get; set; }
        [Required]
        public bool isActive { get; set; }

        [Required]
        public DateTimeOffset UserCreated { get; set; }

        public bool IsAdmin { get; set; } = false;

        public Guid UserIDAdmin { get; set; }

        public DateTimeOffset AdminDateTimeGranted { get; set; }

    }
}
