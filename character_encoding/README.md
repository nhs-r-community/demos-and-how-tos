A simple script that will help you to diagnose character encoding issues. Connect the first bit to your database, and then when you run the rest it will try the same operation on the remote database as well as a SQLite database in memory.

If the SQLite works and your database doesn't then you know it's the database and not your R session that's causing the problem