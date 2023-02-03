FROM mysql:latest

# Add custom configuration file
COPY my.cnf /etc/mysql/conf.d/

# Add a script to initialize the database with sample data
COPY init-db.sh /docker-entrypoint-initdb.d/

# Set environment variables


RUN chmod +x docker-entrypoint-initdb.d
ENTRYPOINT ["/docker-entrypoint-initdb.d"]
EXPOSE 3306 33060 33061
CMD ["mysqld"]
