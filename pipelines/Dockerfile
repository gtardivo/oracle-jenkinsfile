#FROM atf.intranet.bb.com.br:5001/mysql/mysql-server:latest
FROM mysql-server:latest

COPY include/create_developer.sql /scripts/

COPY include/docker-entrypoint.sh /

RUN chmod +x docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306

CMD ["mysqld"]
