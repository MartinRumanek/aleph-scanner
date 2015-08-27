* Aleph Scanner is a web-based tool for searching and querying the Aleph database. 

![aleph_scanner](http://i.imgur.com/hZrG0iG.png)

Contact: honza[\dot]rychtar[\at]gmail[\dot]com

## Requirements
* Docker

## Installation

On debian based systems you can create init script. Create file /etc/init.d/aleph-scanner with following content

```
#!/bin/bash

### BEGIN INIT INFO
# Provides:          aleph-scanner
# Required-Start:    docker
# Required-Stop:     docker
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Aleph-scanner application
# Description:       Runs docker image.
### END INIT INFO

LOCK=/var/lock/aleph-scanner
CONTAINER_NAME=aleph-scanner
IMAGE_NAME=moravianlibrary/aleph-scanner

case "$1" in
  start)
    if [ -f $LOCK ]; then
      echo "Aleph-scanner is running yet."
    else
      touch $LOCK
      echo "Starting aleph-scanner.."
      docker run --name $CONTAINER_NAME -v /var/aleph-scanner:/data -p 9002:8080 $IMAGE_NAME &
      echo "[OK] Aleph-scanner is running."
    fi
    ;;
  stop)
    if [ -f $LOCK ]; then
      echo "Stopping aleph-scanner.."
      rm $LOCK \
        && docker kill $CONTAINER_NAME \
        && docker rm $CONTAINER_NAME \
        && echo "[OK] Aleph-scanner is stopped."
    else
      echo "Aleph-scanner is not running."
    fi
    ;;
  restart)
    $0 stop
    $0 start
  ;;
  status)
    if [ -f $LOCK ]; then
      echo "Aleph-scanner is running."
    else
      echo "Aleph-scanner is not running."
    fi
  ;;
  update)
    docker pull $IMAGE_NAME
    $0 restart
  ;;
  *)
    echo "Usage: /etc/init.d/aleph-scanner {start|stop|restart|status|update}"
    exit 1
    ;;
esac

exit 0
```

After it run these commands

```
# chmod 755 /etc/init.d/aleph-scanner
# update-rc.d aleph-scanner defaults
```

Now the aleph-scanner service will be automatically start at server startup.

Docker container expects directory /var/aleph-scanner, which contains exported data from aleph.

Now you can start service by

```
# /etc/init.d/aleph-scanner start
```

The service listen on port 9002. Now you should install and setup apache http server, which will forward requests to docker container.

```
# apt-get update
# apt-get install apache2
```

In directory /etc/apache2/sites-available create file with name marcscanner.mzk.cz and with content:

```
<VirtualHost *:80>
   ServerName marcscanner.mzk.cz

   <IfModule mod_rewrite.c>
      RewriteEngine on
      Options +FollowSymlinks

      RewriteRule ^/(.*)$  http://localhost:9002/AlephScanner/$1 [P,L]
   </IfModule>
</VirtualHost>
```

After it enable new settings and reload apache server.

```
# a2ensite marcscanner.mzk.cz
# service apache2 reload
```

**Attention**: Docker's default behavior is that it modifies iptables configuration and enables exposed ports defined by -p option. It is possible override this behavior by adding --iptables=false to the Docker daemon.

On Debian based systems, you can edit /etc/default/docker and uncomment the DOCKER_OPTS line:

```
DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4 --iptables=false"
```

After doing that, you need to restart Docker with

```
# /etc/init.d/docker restart
```
