#FROM atf.intranet.bb.com.br:5001/bb/aic/aic-jenkins-slave:3.30.0
FROM atf.intranet.bb.com.br:5001/mysql/mysql-server:latest

COPY include/create_developer.sql /scripts/

COPY include/docker-entrypoint.sh .

RUN chmod +x docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306

CMD ["mysqld"]
