#!/bin/bash
if [[ ! $(id -u) -eq 0 ]] ; then
	echo "You Must Be Root"
	exit 0
fi
if [[ -z $1 ]] ; then
	echo "Useage: setup.sh install|initcfg"
	exit 0
fi
base_dir="/opt/net.techest/tpanel/"
src_dir=${base_dir}"src/"
shell_dir=${base_dir}"install/"

##========================= nginx =========================##
function ins_nginx() {
cd $src_dir
rm nginx-1.4.1 -rf
tar xvf nginx-1.4.1.tar.gz
cd nginx-1.4.1
./configure --prefix=${base_dir}/server/nginx-1.4.1
make && make install
cd $shell_dir
}
function init_nginx() {
rm ${base_dir}server/nginx
cp ${shell_dir}/nginx.conf.default ${base_dir}server/nginx-1.4.1/conf/nginx.conf
ln -s ${base_dir}server/nginx-1.4.1 ${base_dir}server/nginx
}
##========================= mysql =========================##
function ins_mysql() {
cd $src_dir
rm mysql-5.6.12 -rf
tar xvf mysql-5.6.12.tar.gz
cd mysql-5.6.12

cmake -DCMAKE_INSTALL_PREFIX=${base_dir}server/mysql-5.6.12 \
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
##========================= php5.3 =========================##
function ins_php53() {
cd $src_dir
tar xvf php-5.3.26.tar.gz
cd php-5.3.26
./configure --prefix=${base_dir}server/php-5.3.26 \
  --with-mysql \
  --with-pdo-mysql \
  --with-curl \
  --with-gd \
  --enable-fpm \
  --enable-mbstring
make && make install
}
function init_php53() {
rm ${base_dir}server/fpm-php5.3
cp ${shell_dir}php-5.3-fpm.conf.default ${base_dir}server/php-5.3.26/etc/php-fpm.conf
cp ${shell_dir}php-5.3.ini.default ${base_dir}server/php-5.3.26/lib/php.ini
ln -s ${base_dir}server/php-5.3.26 ${base_dir}server/fpm-php5.3
}
##========================= php5.4 =========================##
function ins_php54() {
cd $src_dir
tar xvf php-5.4.16.tar.gz
cd php-5.4.16
./configure --prefix=${base_dir}server/php-5.4.16 \
  --with-mysql \
  --with-pdo-mysql \
  --with-curl \
  --with-gd \
  --enable-fpm \
  --enable-mbstring

make && make install
}

function init_php54() {
rm ${base_dir}server/fpm-php5.4
cp ${shell_dir}php-5.4-fpm.conf.default ${base_dir}server/php-5.4.16/etc/php-fpm.conf
cp ${shell_dir}php-5.4.ini.default ${base_dir}server/php-5.4.16/lib/php.ini
ln -s ${base_dir}server/php-5.4.16 ${base_dir}server/fpm-php5.4
}

##======================== env =============================##
function init_env() {
useradd amm
apt-get install cmake libtool g++ -y
apt-get install libcurl4-openssl-dev libmcrypt-dev libpng++-dev libjpeg-dev libfreetype6-dev -y
apt-get install libncurses5-dev cmake -y
mkdir ${base_dir}etc
mkdir ${base_dir}logs
}

function install() {
init_env

ins_nginx
ins_mysql
ins_python
ins_php53
ins_php54

initcfg
}
function initcfg() {
init_php53
init_php54
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
