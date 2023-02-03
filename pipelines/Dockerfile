#FROM atf.intranet.bb.com.br:5001/mysql/mysql-server:latest
FROM mysql/mysql-server

COPY include/create_developer.sql /scripts/

COPY include/docker-entrypoint.sh /

RUN chmod +x docker-entrypoint.sh

ENTRYPOINT ["bash","docker-entrypoint.sh"]

EXPOSE 3306

CMD ["mysqld"]
