﻿using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.Serialization.Formatters.Binary;
using System.Runtime.Serialization.Json;

namespace Parser
{
    class Program
    {
        static void Main(string[] args)
        {
            var users = new List<User>
            {
                new User
                {
                    Name = "Uladzislau",
                    Department = 3,
                    Email = "uladzislau@techart-group.com"
                },
                new User
                {
                    Name = "Pavel",
                    Department = 3,
                    Email = "Pavel@techart-group.com"
                },
                new User
                {
                    Name = "Dmitry",
                    Department = 3,
                    Email = "Dmitry@techart-group.com"
                },
                new User
                {
                    Name = "Igor",
                    Department = 3,
                    Email = "Igor@techart-group.com"
                }
            };

            using (var stream = new FileStream("users.csv", FileMode.Create, FileAccess.ReadWrite))
            {
                var serializer = new CSVSerializer(typeof(User));
                serializer.Serialize(stream, users);
            }

            List<User> importedUsers = null;
            using (var stream = new FileStream("users.csv", FileMode.Open, FileAccess.Read))
            {
                var serializer = new CSVSerializer(typeof(User));
                importedUsers = serializer.Deserialize(stream).Cast<User>().ToList();

                

            }



            Console.ReadKey();
        }
    }
}