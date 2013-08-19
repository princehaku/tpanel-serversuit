#!/bin/bash 

if [[ ! $(id -u) -eq 0 ]] ; then
	echo "You Must Be Root"
	exit 0
fi

base_dir="/opt/net.techest/tpanel/"
server_dir=$base_dir"server/"

function re_nginx() {
	echo "Restaring Nginx"
	"${server_dir}nginx/sbin/nginx" -s stop
	"${server_dir}nginx/sbin/nginx"
	echo "Done"
}


function re_fpm() {
	echo "Restaring FPM"
	"${server_dir}fpm-php/bin/php" -v
	pkill php
	"${server_dir}fpm-php/sbin/php-fpm"
	echo "Done"
}

function re_mysql() {
	echo "Restaring Mysql"

}

if [[ -z $1 ]] ; then
	re_nginx
	re_fpm
	re_mysql
else
	re_$1
fi
