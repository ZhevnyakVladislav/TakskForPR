using System;

namespace Parser
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Property)]
    public class CSVSerializableAttribute : Attribute
    {
        public string ColumnName;

        public CSVSerializableAttribute() { }

        public CSVSerializableAttribute(string columnName)
        {
            ColumnName = columnName;
        }
    }
}
