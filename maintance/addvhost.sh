#!/bin/bash
if [[ $(id -u) -ne 0 ]]; then
   echo "You Must Be Root"
   exit 0
fi

base_dir="/opt/net.techest/tpanel/"
etc_dir=$base_dir"etc/"
server_dir=$base_dir"server/"

echo "please input domain name (without www)"
read -p "domain:" temp
if [[ "$temp" != "" ]]; then
   domain_name=$temp
fi
user_name=$(who am i | cut -d " " -f 1)
echo "+--------------------------------------+"
echo "+              checking user           +"
echo "+--------------------------------------+"
user_pwd=$(echo "123" | cut -d " " -f 1)
user_pwd=${user_pwd:0:5}

echo "+--------------------------------------+"
echo "+              adding vhost            +"
echo "+--------------------------------------+"
mkdir -p /Users/$user_name/htdocs/$domain_name
chown -R ${user_name} /Users/$user_name/htdocs/$domain_name
# init fpm poll
cp configs/fpm-poll.conf.default ${etc_dir}fpm.d/$domain_name.conf
sed -i '' -e "s/{{user_name}}/${user_name}/g" ${etc_dir}fpm.d/$domain_name.conf
sed -i '' -e "s/{{domain_name}}/${domain_name}/g" ${etc_dir}fpm.d/$domain_name.conf
# init nginx port
cp configs/nginx.vhosts.conf.default ${etc_dir}nginx.d/$domain_name.conf
sed -i '' -e "s/{{user_name}}/${user_name}/g" ${etc_dir}nginx.d/$domain_name.conf
sed -i '' -e "s/{{domain_name}}/${domain_name}/g" ${etc_dir}nginx.d/$domain_name.conf

echo "127.0.0.1     ${domain_name}" >> /etc/hosts
./restart.sh
echo "+--------------------------------------+"
echo "+              finish                  +"
echo "+--------------------------------------+"
