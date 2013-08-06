#!/bin/bash
if [[ ! $(id -u) -eq 0 ]] ; then
    echo "You Must Be Root"
    #exit 0
fi
if [[ -z $1 ]] ; then
    echo "Useage: setup.sh install|initcfg"
    exit 0
fi

nginx_version=1.4.2
php_version=5.4.16
mysql_version=5.6.12

nginx_dist_url=http://nginx.org/download/nginx-${nginx_version}.tar.gz
php_dist_url=http://www.php.net/distributions/php-${php_version}.tar.gz
mysql_dist_url=http://cdn.mysql.com/Downloads/MySQL-5.6/mysql-${mysql_version}.tar.gz

base_dir="/opt/net.techest/tpanel/"
src_dir=${base_dir}"src/"
shell_dir=${base_dir}"install/"

##========================= nginx =========================##
function ins_nginx() {
    cd $src_dir
    rm nginx-${nginx_version} -rf
    tar xvf nginx-${nginx_version}.tar.gz
    cd nginx-${nginx_version}
    ./configure --prefix=${base_dir}/server/nginx-${nginx_version}
    make && make install
    cd $shell_dir
}

function init_nginx() {
    rm ${base_dir}server/nginx
    cp ${shell_dir}/nginx.conf.default ${base_dir}server/nginx-${nginx_version}/conf/nginx.conf
    ln -s ${base_dir}server/nginx-${nginx_version} ${base_dir}server/nginx
    mkdir ${base_dir}etc/nginx.d
}
##========================= mysql =========================##
function ins_mysql() {
    cd $src_dir
    rm mysql-${mysql_version} -rf
    tar xvf mysql-${mysql_version}.tar.gz
    cd mysql-${mysql_version}

    cmake -DCMAKE_INSTALL_PREFIX=${base_dir}server/mysql-${mysql_version} \
      -DDEFAULT_CHARSET=utf8 \
      -DDEFAULT_COLLATION=utf8_unicode_ci \
      -DWITH_EXTRA_CHARSETS=all \
      -DWITH_DEBUG=0 \
      -DWITH_UNIT_TESTS=0

    make && make install
}
##========================= python =========================##
function ins_python() {
    cd $src_dir
    tar xvf Python-2.7.5.tgz
    cd Python-2.7.5
    ./configure --prefix=${base_dir}shared/python-2.7.5
    make && make install
    cd $src_dir
    #init pip
    ${base_dir}shared/python-2.7.5/bin/python ez_setup.py
}
##========================= php =========================##
function ins_php() {
    cd ${src_dir}
    tar xvf php-${php_version}.tar.gz
    cd php-${php_version}
    ./configure --prefix=${base_dir}server/php-${php_version} \
      --with-mysql \
      --with-pdo-mysql \
      --with-curl \
      --with-gd \
      --enable-fpm \
      --enable-mbstring

    make && make install
}

function init_php() {
    rm ${base_dir}server/fpm-php
    cp ${shell_dir}php-5.4-fpm.conf.default ${base_dir}server/php-${php_version}/etc/php-fpm.conf
    cp ${shell_dir}php-5.4.ini.default ${base_dir}server/php-${php_version}/lib/php.ini
    ln -s ${base_dir}server/php-${php_version} ${base_dir}server/fpm-php
    mkdir ${base_dir}etc/fpm.d
}

##======================== env =============================##
function init_env() {
    useradd amm
    apt-get install cmake libtool g++ -y
    apt-get install libcurl4-openssl-dev libmcrypt-dev libpng++-dev libjpeg-dev libfreetype6-dev -y
    apt-get install libncurses5-dev cmake -y
    mkdir -p ${base_dir}
    mkdir ${base_dir}/etc
    mkdir ${base_dir}/logs
    mkdir -p ${src_dir}
}

function check_src() {
    cd ${src_dir}
    if [[ ! -f nginx-${nginx_version}.tar.gz ]] ; then
        wget ${nginx_dist_url} nginx-${nginx_version}.tar.gz
    fi
    if [[ ! -f php-${php_version}.tar.gz ]] ; then
        wget ${php_dist_url} php-${php_version}.tar.gz
    fi
    if [[ ! -f mysql-${mysql_version}.tar.gz ]] ; then
        wget ${mysql_dist_url} mysql-${mysql_version}.tar.gz
    fi
}

function install() {
    init_env
    check_src

    ins_nginx
    ins_mysql
    ins_php

    initcfg
}

function initcfg() {
    init_php
    init_nginx
}

if [[ $1 = 'install' ]] ; then
    install
    echo "Done"
    exit
fi
if [[ $1 = 'clear' ]] ; then
    find ${src_dir}* -maxdepth 0 -type d | xargs rm -rf
    echo "Done"
    exit
fi
if [[ $1 = 'initcfg' ]] ; then
    initcfg
    echo "Done"
    exit
fi
$1
exit
