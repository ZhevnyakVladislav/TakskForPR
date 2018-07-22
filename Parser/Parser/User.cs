using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using System.Xml;
using System.Xml.Serialization;

namespace Parser
{
    [CSVSerializable]
    public class User
    {
        public string Name { get; set; }

        [CSVSerializable("User Email")]
        public string Email { get; set; }

        [CSVSerializable("User Department")]
        public int Department { get; set; }
    }
}
