#!/bin/bash
# Wait until MariaDB started and listens on port 3306.
until $(nc -z db 3306); do { printf '.'; sleep 1; }; done

# Start server.
/usr/bin/freeswitch -rp -nonat -u www-data -g www-data
