using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.Serialization;
using System.Text;

namespace Parser
{
    public class CSVSerializer<T>
    {
        private readonly Type _type;

        private readonly List<PropertyInfo> _properties;

        private readonly bool _isSerializable;

        public CSVSerializer()
        {
            _type = typeof(T);
            _properties = _type.GetProperties().ToList();
            _isSerializable = _type.GetCustomAttributes(typeof(Attribute), true).Any(x => x is CSVSerializableAttribute) ? true : throw new SerializationException();
        }

        public void Serialize(Stream stream, ICollection objects)
        {
            if (stream == null)
                throw new ArgumentNullException(nameof(stream), $"ArgumentNull_WithParamName{(object)stream}");

            if (_isSerializable)
            {
                var sb = new StringBuilder();
                var values = new List<string>();

                sb.AppendLine(string.Join(",", GetHeader()));

                var row = 1;
                foreach (var item in objects)
                {
                    values.Clear();

                    foreach (var p in _properties)
                    {
                        var raw = p.GetValue(item);
                        var value = raw == null ? "" : raw.ToString();

                        values.Add(value);
                    }
                    sb.AppendLine(string.Join(",", values));
                }

                using (var sw = new StreamWriter(stream))
                {
                    sw.Write(sb.ToString().Trim());
                }
            }
        }

        public ICollection Deserialize(Stream stream)
        {
            string[] columns;
            string[] rows;
            
            try
            {
                using (var streamReader = new StreamReader(stream))
                {
                    columns = streamReader.ReadLine().Split(",");
                    rows = streamReader.ReadToEnd().Split(new string[] { Environment.NewLine }, StringSplitOptions.None);
                }
            }
            catch (Exception e)
            {
                throw new InvalidCastException("The CSV file is invalid", e);
            }

            var data = new List<object>();
            for (int i = 0; i < rows.Length; i++)
            {
                var line = rows[i];

                if (string.IsNullOrWhiteSpace(line))
                {
                    throw new InvalidCastException($"Empty line at line number {i}");
                }

                var parts = line.Split(',');
                var obj = Activator.CreateInstance(_type);

                for (int j = 0; j < parts.Length; j++)
                {
                    var value = parts[j];
                    var column = columns[j];

                    var property = GetProperty(column);
                    var converter = TypeDescriptor.GetConverter(property.PropertyType);
                    var convertedValue = converter.ConvertFrom(value);

                    property.SetValue(obj, convertedValue, null);

                }

                data.Add(obj);
            }

            return data;
        }

        private List<string> GetHeader()
        {
            var headerColumns = new List<string>();

            foreach (var propertyInfo in _properties)
            {
                var attributes = propertyInfo.GetCustomAttributes(true);
                var csvAttribute = (CSVSerializableAttribute)attributes.FirstOrDefault(attribute => attribute is CSVSerializableAttribute);
                var columnName = csvAttribute != null ? csvAttribute.ColumnName : propertyInfo.Name;

                headerColumns.Add(columnName);
            }

            return headerColumns;
        }

        private PropertyInfo GetProperty(string columnName)
        {
            var property = _properties.FirstOrDefault(prop =>
            {
                var attr = (CSVSerializableAttribute) prop.GetCustomAttributes(true).FirstOrDefault(attribute => attribute is CSVSerializableAttribute);

                return attr?.ColumnName == columnName;
            });

            property = property != null ? property : _properties.FirstOrDefault(prop => prop.Name == columnName);

            return property;
        }
    }
}