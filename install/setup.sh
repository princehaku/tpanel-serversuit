#!/bin/bash
if [[ ! $(id -u) -eq 0 ]] ; then
    echo "You Must Be Root"
    exit 0
fi
if [[ -z $1 ]] ; then
    echo "Useage: setup.sh install php|nginx|mysql|python"
    exit 0
fi

nginx_version=1.4.2
php_version=5.4.16
mysql_version=5.5.33

nginx_dist_url=http://nginx.org/download/nginx-${nginx_version}.tar.gz
php_dist_url=http://www.php.net/distributions/php-${php_version}.tar.gz
mysql_dist_url=http://cdn.mysql.com/Downloads/MySQL-5.5/mysql-${mysql_version}.tar.gz

base_dir="/opt/net.techest/tpanel/"
src_dir=${base_dir}"src/"
shell_dir=$(pwd)

##========================= nginx =========================##
function check_nginx() {
    cd ${src_dir}
    wget -c ${nginx_dist_url} -Onginx-${nginx_version}.tar.gz
    apt-get install libpcre3-dev zlib-bin libssl-dev -y
}
function ins_nginx() {
    cd $src_dir
    if [[ -f ${base_dir}/server/nginx-${nginx_version}/sbin/nginx ]] ; then
        echo "Nginx Existed"
        return
    fi
    rm nginx-${nginx_version} -rf
    tar xvf nginx-${nginx_version}.tar.gz
    cd nginx-${nginx_version}
    ./configure --prefix=${base_dir}/server/nginx-${nginx_version}
    make && make install
    if [[ ! -f ${base_dir}/server/nginx-${nginx_version}/sbin/nginx ]] ; then
        echo "Nginx Install Failed"
        exit 0
    fi
}

function init_nginx() {
    cp ${shell_dir}/configs/nginx.conf.default ${base_dir}/server/nginx-${nginx_version}/conf/nginx.conf
    cp ${shell_dir}/configs/fastcgi_params ${base_dir}/server/nginx-${nginx_version}/conf/fastcgi_params
    ln -f -s ${base_dir}/server/nginx-${nginx_version} ${base_dir}/server/nginx
    mkdir ${base_dir}/etc/nginx.d
}
##========================= mysql =========================##
function check_mysql() {
    cd ${src_dir}
    apt-get install libncurses5-dev cmake -y
    wget -c ${mysql_dist_url} -Omysql-${mysql_version}.tar.gz
}
function ins_mysql() {
    cd $src_dir
    if [[ -f ${base_dir}/server/mysql-${mysql_version}/bin/mysqld ]] ; then
        echo "Mysqld Existed"
        return
    fi
    rm mysql-${mysql_version} -rf
    tar xvf mysql-${mysql_version}.tar.gz
    cd mysql-${mysql_version}

    cmake -DCMAKE_INSTALL_PREFIX=${base_dir}/server/mysql-${mysql_version} \
      -DDEFAULT_CHARSET=utf8 \
      -DDEFAULT_COLLATION=utf8_unicode_ci \
      -DWITH_EXTRA_CHARSETS=all \
      -DWITH_DEBUG=0 \
      -DWITH_UNIT_TESTS=0

    make && make install
    
    if [[ ! -f ${base_dir}/server/mysql-${mysql_version}/bin/mysqld ]] ; then
        echo "Mysql Install Failed"
        exit 0
    fi
}
function init_mysql() {
    ln -f -s ${base_dir}/server/mysql-${mysql_version} ${base_dir}/server/mysql
    if [[ ! -f ${base_dir}etc/mysql/my.cnf ]] ; then
	    cd ${base_dir}/server/mysql
	    chown amm:amm ${base_dir}/server/mysql -R
	    mkdir -p ${base_dir}/etc/mysql/
	    cp ./support-files/my-medium.cnf ${base_dir}/etc/mysql/my.cnf
	    chown amm:amm ${base_dir}/etc/mysql/my.cnf
	    ./scripts/mysql_install_db --basedir=${base_dir}/server/mysql --datadir=${base_dir}/server/mysql/data --user=amm
	    ./bin/mysqld --defaults-file="${base_dir}etc/mysql/my.cnf" --user=amm &
	    ./bin/mysqladmin -u root password "hello_tpanel"
    fi
}
##========================= php =========================##
function check_php() {
    cd ${src_dir}
    apt-get install libxml2-dev libcurl4-openssl-dev libmcrypt-dev libpng-dev libjpeg-dev libfreetype6-dev -y
    wget -c ${php_dist_url} -Ophp-${php_version}.tar.gz
}
function ins_php() {
    cd ${src_dir}
    if [[ -f ${base_dir}/server/php-${php_version}/bin/php ]] ; then
        echo "PHP Binary Existed"
        return
    fi
    tar xvf php-${php_version}.tar.gz
    cd php-${php_version}
    ./configure --prefix=${base_dir}/server/php-${php_version} \
      --with-mysql \
      --with-pdo-mysql \
      --with-mcrypt \
      --with-curl \
      --with-gd \
      --with-jpeg-dir=/usr/lib \
      --with-png-dir=/usr/lib \
      --with-freetype-dir=/usr/lib \
      --enable-fpm \
      --enable-mbstring

    make && make install
    
    if [[ ! -f ${base_dir}/server/php-${php_version}/bin/php ]] ; then
        echo "PHP Install Failed"
        exit 0
    fi
}

function init_php() {
    cd ${shell_dir}
    cp ${shell_dir}/configs/php-fpm.conf.default ${base_dir}/server/php-${php_version}/etc/php-fpm.conf
    cp ${shell_dir}/configs/php.ini.default ${base_dir}/server/php-${php_version}/lib/php.ini
    ln -f -s ${base_dir}/server/php-${php_version} ${base_dir}/server/fpm-php
    mkdir ${base_dir}/etc/fpm.d
}

##======================== env =============================##
function init_env() {
    cd ${shell_dir}
    useradd amm
    apt-get install libtool g++ -y
}

function init_dirs() {
    mkdir -p ${base_dir}
    mkdir ${base_dir}/etc
    mkdir ${base_dir}/logs
    mkdir ${base_dir}/server
    mkdir -p ${src_dir}
    cd ${shell_dir}/../
    cp maintance ${base_dir} -R
}

function install() {
    # env init
    if [[ ! -f .env_ready ]] ; then
        init_env
    fi
    init_dirs
    touch .env_ready

    # 根据指令安装

    if [[ -z $1 ]] ; then
        check_nginx
        ins_nginx
        init_nginx

        check_mysql
        ins_mysql
        init_mysql

        check_php
        ins_php
        init_php
    else
        check_$1
        ins_$1
        init_$1
    fi
}

if [[ $1 = 'install' ]] ; then
    install $2
    echo "Done"
    exit
fi

if [[ $1 = 'clear' ]] ; then
    find ${src_dir}* -maxdepth 0 -type d | xargs rm -rf
    rm ${base_dir} -rf
    echo "Done"
    exit
fi
exit
