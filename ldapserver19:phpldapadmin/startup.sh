#!/bin/bash

bash /opt/docker/install.sh
/sbin/php-fpm
/sbin/httpd -D FOREGROUND