# #!/bin/bash
# # Start the MySQL daemon
# /usr/bin/mysqld &

# # Wait for the MySQL daemon to start
# sleep 10

# # Create a new database and user
# mysql --user=root <<-EOSQL
#     CREATE DATABASE DEVAPP;
#     CREATE USER 'myuser'@'%' IDENTIFIED BY 'password';
#     GRANT ALL PRIVILEGES ON mydb.* TO 'myuser'@'%';
# EOSQL

# # Stop the MySQL daemon
# mysqladmin -uroot shutdown
#!/bin/bash

set -e

if [ "${1:0:1}" = '-' ]; then
    set -- mysqld "$@"
fi

if [ "$1" = 'mysqld' ]; then
    # Get config
    DATADIR="$("$@" --verbose --help --log-bin-index="$(mktemp -u)" 2>/dev/null | awk '$1 == "datadir" { print $2; exit }')"

    if [ ! -d "$DATADIR/mysql" ]; then
        if [ -z "$MYSQL_ROOT_PASSWORD" -a -z "$MYSQL_ALLOW_EMPTY_PASSWORD" ]; then
            echo >&2 'error: database is uninitialized and MYSQL_ROOT_PASSWORD not set'
            echo >&2 '  Did you forget to add -e MYSQL_ROOT_PASSWORD=... ?'
            exit 1
        fi

        echo 'Initializing database'
        "$@" --initialize-insecure
        echo 'Database initialized'

        "$@" --skip-networking &
        pid="$!"

        mysql=( mysql --protocol=socket -uroot )

        for i in {30..0}; do
            if echo 'SELECT 1' | "${mysql[@]}" &> /dev/null; then
                break
            fi
            echo 'MySQL init process in progress...'
            sleep 1
        done
        if [ "$i" = 0 ]; then
            echo >&2 'MySQL init process failed.'
            exit 1
        fi

        if [ -z "$MYSQL_INITDB_SKIP_TZINFO" ]; then
            # sed is for https://bugs.mysql.com/bug.php?id=20545
            mysql_tzinfo_to_sql /usr/share/zoneinfo | sed 's/Local time zone must be set--see zic manual page/FCTY/' | "${mysql[@]}" mysql
        fi

        if [ ! -z "$MYSQL_RANDOM_ROOT_PASSWORD" ]; then
            MYSQL_ROOT_PASSWORD="$(pwgen -1 32)"
            echo "GENERATED ROOT PASSWORD: $MYSQL_ROOT_PASSWORD"
        fi

        rootCreate=
        # default root to listen for connections from anywhere
        if [ ! -z "$MYSQL_ROOT_HOST" -a "$MYSQL_ROOT_HOST" != 'localhost' ]; then
            # no, we don't care if read discovers a rogue carriage return
            read -r -d '' rootCreate <<-E
