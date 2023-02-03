FROM mysql/mysql-server:8.0.23-1.1.19

COPY include/create_developer.sql /scripts/

COPY include/docker-entrypoint.sh /

RUN chmod +x docker-entrypoint.sh

ENV MYSQL_ROOT_PASSWORD="123456"

ENTRYPOINT ["bash","docker-entrypoint.sh"]

EXPOSE 3306

CMD ["mysqld"]
