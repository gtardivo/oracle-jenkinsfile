#!/bin/bash

# Start the MySQL daemon
/usr/bin/mysqld_safe &

# Wait for the MySQL daemon to start
sleep 10s

# Create a new database and user
mysql --user=root <<-EOSQL
    CREATE DATABASE mydb;
    CREATE USER 'myuser'@'%' IDENTIFIED BY 'password';
    GRANT ALL PRIVILEGES ON mydb.* TO 'myuser'@'%';
EOSQL

# Stop the MySQL daemon
mysqladmin -uroot shutdown
