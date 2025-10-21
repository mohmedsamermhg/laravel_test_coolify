#!/bin/sh

# Initialize MySQL if not already initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Start MySQL temporarily
    mysqld --user=mysql --skip-networking &
    MYSQL_PID=$!

    # Wait for MySQL to start
    sleep 5

    # Create database and user
    mysql -u root <<-EOF
        CREATE DATABASE IF NOT EXISTS laravel;
        CREATE USER IF NOT EXISTS 'laravel'@'localhost' IDENTIFIED BY 'password';
        GRANT ALL PRIVILEGES ON laravel.* TO 'laravel'@'localhost';
        FLUSH PRIVILEGES;
EOF

    # Stop temporary MySQL
    kill $MYSQL_PID
    wait $MYSQL_PID
fi

# Start supervisord
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
