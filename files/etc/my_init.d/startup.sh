#!/bin/bash

export TERM=xterm

if [ -z "`ls /vesta --hide='lost+found'`" ]
then
    rsync -a /vesta-start/* /vesta
    rsync -a /sysprepz/home/* /home    
fi

# attempt to recover permission, but it's best to just reinstall
if [ "$(stat -c %U /vesta/var/lib/mysql)" != "mysql" ]; then
    chown -R mysql:mysql /vesta/var/lib/mysql

    chown -R couchdb:couchdb /vesta/var/lib/couchdb
    chown -R couchdb:couchdb /vesta/etc/couchdb

    chown -R postgres:postgres /vesta/var/lib/postgresql

    chown -R redis:redis /vesta/var/lib/redis
    chown redis:redis /vesta/etc/redis/redis.conf

    chown -R mongodb:mongodb /vesta/data/db

    chown -R admin:admin /home/admin
    chown -R root:root /home/admin/conf
    chown -R Debian-exim:mail /home/admin/conf/mail/*
    chown root:bind /home/admin/conf/dns/*.*
    chown root:admin /home/admin/conf/web/*.*
    chown root:root /home/admin/mail
    chown -R admin:mail /home/admin/mail/*

    chown root:bind /vesta/etc/bind
    chown root:bind /vesta/etc/bind/name*.*
    chown bind:bind /vesta/etc/bind/rndc.key
    chown root:Debian-exim /vesta/etc/exim4/passwd.client
    chown admin:admin /vesta/etc/fail2ban/action.d/vesta.conf
    chown admin:admin /vesta/etc/fail2ban/action.d
    chown admin:admin /vesta/etc/fail2ban/filter.d/vesta.conf
    chown admin:admin /vesta/etc/fail2ban/jail.local

    chown -R admin:root /vesta/local/vesta/nginx/*_temp/

    chown -R admin:admin /vesta/local/vesta/data/firewall
    chown -R admin:admin /vesta/local/vesta/data/packages
    chown -R admin:admin /vesta/local/vesta/data/sessions
    chown root:admin /vesta/local/vesta/data/sessions
    chown -R root:admin /vesta/local/vesta/data/templates

    # finally, reset logs because it is too complicated
    mv /vesta/var/log /vesta/var/log-old
    rsync -a /vesta-start/var/log /vesta/var/log
fi


# restore current users
if [[ -f /backup/.etc/passwd ]]; then
	# restore users
	rsync -a /backup/.etc/passwd /etc/passwd
	rsync -a /backup/.etc/shadow /etc/shadow
	rsync -a /backup/.etc/gshadow /etc/gshadow
	rsync -a /backup/.etc/group /etc/group
fi

# start incron after restore
cd /etc/init.d/
./incron start

# starting Vesta
bash /home/admin/bin/my-startup.sh
