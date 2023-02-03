FROM mysql:latest

# Add custom configuration file
COPY my.cnf /etc/mysql/conf.d/

# Add a script to initialize the database with sample data
COPY init-db.sh init-db.sh

# Set environment variables


RUN chmod +x init-db.sh
ENTRYPOINT ["/init-db.sh"]
EXPOSE 3306 33060 33061
CMD ["mysqld"]
