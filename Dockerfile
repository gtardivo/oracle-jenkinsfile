FROM mysql:latest

# Add custom configuration file
COPY my.cnf /etc/mysql/conf.d/

# Add a script to initialize the database with sample data
COPY init-db.sh /docker-entrypoint-initdb.d/

# Set environment variables for custom configuration
ENV DB_PASSWORD=your_password
ENV DB_NAME=your_database
ENV DB_USER=your_user
ENV DEV_DB_PASSWORD=your_password
