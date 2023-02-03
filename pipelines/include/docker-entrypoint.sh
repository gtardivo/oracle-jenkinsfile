#!/bin/bash
# Start the MySQL daemon
/usr/bin/mysqld &

# Wait for the MySQL daemon to start
sleep 10

# Create a new database and user
mysql --user=root <<-EOSQL
    CREATE DATABASE DEVAPP;
    CREATE USER 'myuser'@'%' IDENTIFIED BY 'password';
    GRANT ALL PRIVILEGES ON mydb.* TO 'myuser'@'%';
EOSQL

# Stop the MySQL daemon
mysqladmin -uroot shutdown
